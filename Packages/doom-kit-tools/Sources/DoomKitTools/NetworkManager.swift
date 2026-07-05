import Foundation
import Network

public actor NetworkManager {
    public static let shared = NetworkManager()

    private let monitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "NetworkMonitor")
    public private(set) var isConnected = false
    public private(set) var connectionType: ConnectionType = .unknown
    private var isMonitoringStarted = false
    private var initialConnectionCheckCompleted = false

    private let maxRetryAttempts = 5

    public enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown
    }

    private init() {}

    private nonisolated func setupMonitor() {
        self.monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else {
                return
            }
            Task {
                await self.updateConnectionStatus(path: path)
            }
        }
    }

    public func startMonitoring() async {
        guard self.isMonitoringStarted == false else {
            return
        }

        self.setupMonitor()
        self.monitor.start(queue: self.monitorQueue)
        self.isMonitoringStarted = true

        await self.waitForInitialConnectionCheck()
    }

    private func waitForInitialConnectionCheck() async {
        let timeout = Task {
            try? await Task.sleep(for: .seconds(5))
            await self.setInitialConnectionCheckCompleted()
        }

        while self.initialConnectionCheckCompleted == false {
            try? await Task.sleep(for: .milliseconds(100))
            if timeout.isCancelled {
                break
            }
        }

        timeout.cancel()
    }

    private func setInitialConnectionCheckCompleted() async {
        self.initialConnectionCheckCompleted = true
    }

    private func updateConnectionStatus(path: NWPath) async {
        let wasConnected = self.isConnected
        self.isConnected = path.status == .satisfied
        self.getConnectionType(path)

        if self.initialConnectionCheckCompleted == false {
            self.initialConnectionCheckCompleted = true
        }

        if wasConnected != self.isConnected {
            NotificationCenter.default.post(name: .networkStatusChanged, object: nil)
        }
    }

    public func stopMonitoring() {
        guard self.isMonitoringStarted else {
            return
        }
        self.monitor.cancel()
        self.isMonitoringStarted = false
        self.initialConnectionCheckCompleted = false
    }

    private func getConnectionType(_ path: NWPath) {
        if path.usesInterfaceType(.wifi) {
            self.connectionType = .wifi
        }
        else if path.usesInterfaceType(.cellular) {
            self.connectionType = .cellular
        }
        else if path.usesInterfaceType(.wiredEthernet) {
            self.connectionType = .ethernet
        }
        else {
            self.connectionType = .unknown
        }
    }

    public func performRequest<T: Decodable>(
        urlString: String,
        method: String = "GET",
        body: Data? = nil,
        headers: [String: String]? = nil,
        decoder: JSONDecoder = JSONDecoder()
    ) async -> Result<T, NetworkError> {
        if self.isMonitoringStarted == false {
            await self.startMonitoring()
        }

        return await self.attemptRequest(
            urlString: urlString,
            method: method,
            body: body,
            headers: headers,
            decoder: decoder,
            attempt: 1
        )
    }

    private func attemptRequest<T: Decodable>(
        urlString: String,
        method: String,
        body: Data?,
        headers: [String: String]?,
        decoder: JSONDecoder,
        attempt: Int
    ) async -> Result<T, NetworkError> {
        if self.initialConnectionCheckCompleted == false {
            let waitResult = await self.waitForConnection(timeoutSeconds: 10)
            if case .failure = waitResult {
                return .failure(.networkUnavailable)
            }
        }

        if self.isConnected == false {
            let connectivityResult = await self.checkActualConnectivity()
            if case .failure = connectivityResult {
                let waitResult = await self.waitForConnection(timeoutSeconds: 15)
                if case .failure = waitResult {
                    return .failure(.networkUnavailable)
                }
            }
        }

        guard let url = URL(string: urlString) else {
            return .failure(.invalidURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = method

        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }

        if let body = body {
            request.httpBody = body
        }

        let dataResult: Result<(Data, HTTPURLResponse), NetworkError>

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(.invalidResponse)
            }

            dataResult = .success((data, httpResponse))
        }
        catch let urlError as URLError {
            let networkError: NetworkError
            switch urlError.code {
                case .notConnectedToInternet, .networkConnectionLost:
                    networkError = .networkUnavailable
                case .timedOut:
                    networkError = .timeout
                case .cancelled:
                    networkError = .taskCancelled
                default:
                    networkError = .invalidResponse
            }

            if attempt < self.maxRetryAttempts {
                let delaySeconds = min(pow(2.0, Double(attempt)), 60.0)

                do {
                    try await Task.sleep(for: .seconds(delaySeconds))
                }
                catch {
                    return .failure(.taskCancelled)
                }

                return await self.attemptRequest(
                    urlString: urlString,
                    method: method,
                    body: body,
                    headers: headers,
                    decoder: decoder,
                    attempt: attempt + 1
                )
            }

            return .failure(networkError)
        }
        catch {
            return .failure(.invalidResponse)
        }

        switch dataResult {
            case .success((let data, let httpResponse)):
                guard (200 ... 299).contains(httpResponse.statusCode) else {
                    if (500 ... 599).contains(httpResponse.statusCode) && attempt < self.maxRetryAttempts {
                        let delaySeconds = min(pow(2.0, Double(attempt)), 60.0)
                        trace.debug(
                            "Server error \(httpResponse.statusCode), retrying in \(delaySeconds)s (attempt \(attempt)/\(self.maxRetryAttempts))")

                        do {
                            try await Task.sleep(for: .seconds(delaySeconds))
                        }
                        catch {
                            return .failure(.taskCancelled)
                        }

                        return await self.attemptRequest(
                            urlString: urlString,
                            method: method,
                            body: body,
                            headers: headers,
                            decoder: decoder,
                            attempt: attempt + 1
                        )
                    }
                    return .failure(.serverError(statusCode: httpResponse.statusCode))
                }

                do {
                    let decodedData = try decoder.decode(T.self, from: data)
                    return .success(decodedData)
                }
                catch {
                    return .failure(.decodingError(error: error))
                }

            case .failure(let error):
                return .failure(error)
        }
    }

    private func checkActualConnectivity() async -> Result<Void, NetworkError> {
        guard let url = URL(string: "https://www.apple.com/library/test/success.html") else {
            return .failure(.invalidURL)
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 10
        request.httpMethod = "HEAD"

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse,
                (200 ... 299).contains(httpResponse.statusCode)
            {
                return .success(())
            }
            else {
                return .failure(.networkUnavailable)
            }
        }
        catch {
            return .failure(.networkUnavailable)
        }
    }

    private func waitForConnection(timeoutSeconds: Double) async -> Result<Void, NetworkError> {
        if self.isConnected {
            return await self.checkActualConnectivity()
        }

        return await withCheckedContinuation { continuation in
            let connectionMonitor = NWPathMonitor()
            let monitorQueue = DispatchQueue(label: "ConnectionWaitMonitor")
            let connectionWaiter = ConnectionWaiter()

            let timeoutTask = Task {
                try? await Task.sleep(for: .seconds(timeoutSeconds))
                let didComplete = await connectionWaiter.tryComplete()
                if didComplete {
                    connectionMonitor.cancel()
                    continuation.resume(returning: .failure(.timeout))
                }
            }

            connectionMonitor.start(queue: monitorQueue)
            connectionMonitor.pathUpdateHandler = { path in
                if path.status == .satisfied {
                    Task {
                        let didComplete = await connectionWaiter.tryComplete()
                        if didComplete {
                            timeoutTask.cancel()
                            connectionMonitor.cancel()

                            let connectivityResult = await self.checkActualConnectivity()
                            continuation.resume(returning: connectivityResult)
                        }
                    }
                }
            }
        }
    }

    public func performDataRequest(
        urlString: String,
        method: String = "GET",
        body: Data? = nil,
        headers: [String: String]? = nil
    ) async -> Result<Data, NetworkError> {
        if self.isMonitoringStarted == false {
            await self.startMonitoring()
        }

        return await self.attemptDataRequest(
            urlString: urlString,
            method: method,
            body: body,
            headers: headers,
            attempt: 1
        )
    }

    private func attemptDataRequest(
        urlString: String,
        method: String,
        body: Data?,
        headers: [String: String]?,
        attempt: Int
    ) async -> Result<Data, NetworkError> {
        if self.initialConnectionCheckCompleted == false {
            let waitResult = await self.waitForConnection(timeoutSeconds: 10)
            if case .failure = waitResult {
                return .failure(.networkUnavailable)
            }
        }

        if self.isConnected == false {
            let connectivityResult = await self.checkActualConnectivity()
            if case .failure = connectivityResult {
                let waitResult = await self.waitForConnection(timeoutSeconds: 15)
                if case .failure = waitResult {
                    return .failure(.networkUnavailable)
                }
            }
        }

        guard let url = URL(string: urlString) else {
            return .failure(.invalidURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = method

        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }

        if let body = body {
            request.httpBody = body
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(.invalidResponse)
            }

            guard (200 ... 299).contains(httpResponse.statusCode) else {
                if (500 ... 599).contains(httpResponse.statusCode) && attempt < self.maxRetryAttempts {
                    let delaySeconds = min(pow(2.0, Double(attempt)), 60.0)
                    trace.debug(
                        "Server error \(httpResponse.statusCode), retrying in \(delaySeconds)s (attempt \(attempt)/\(self.maxRetryAttempts))")

                    do {
                        try await Task.sleep(for: .seconds(delaySeconds))
                    }
                    catch {
                        return .failure(.taskCancelled)
                    }

                    return await self.attemptDataRequest(
                        urlString: urlString,
                        method: method,
                        body: body,
                        headers: headers,
                        attempt: attempt + 1
                    )
                }
                return .failure(.serverError(statusCode: httpResponse.statusCode))
            }

            return .success(data)
        }
        catch let urlError as URLError {
            let networkError: NetworkError
            switch urlError.code {
                case .notConnectedToInternet, .networkConnectionLost:
                    networkError = .networkUnavailable
                case .timedOut:
                    networkError = .timeout
                case .cancelled:
                    networkError = .taskCancelled
                default:
                    networkError = .invalidResponse
            }

            if attempt < self.maxRetryAttempts {
                let delaySeconds = min(pow(2.0, Double(attempt)), 60.0)

                do {
                    try await Task.sleep(for: .seconds(delaySeconds))
                }
                catch {
                    return .failure(.taskCancelled)
                }

                return await self.attemptDataRequest(
                    urlString: urlString,
                    method: method,
                    body: body,
                    headers: headers,
                    attempt: attempt + 1
                )
            }

            return .failure(networkError)
        }
        catch {
            return .failure(.invalidResponse)
        }
    }
}

import Foundation
import Network

// Network error types
enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case serverError(statusCode: Int)
    case noData
    case decodingError(error: Error)
    case networkUnavailable
    case taskCancelled
    case timeout
}

actor NetworkManager {
    static let shared = NetworkManager()

    private let monitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "NetworkMonitor")
    private(set) var isConnected = false
    private(set) var connectionType: ConnectionType = .unknown
    private var isMonitoringStarted = false
    private var initialConnectionCheckCompleted = false

    // Maximum number of retry attempts
    private let maxRetryAttempts = 5

    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown
    }

    private init() {
        // Don't start monitoring immediately - wait for explicit call
    }

    private nonisolated func setupMonitor() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }

            Task {
                await self.updateConnectionStatus(path: path)
            }
        }
    }

    func startMonitoring() async {
        guard !isMonitoringStarted else { return }

        setupMonitor()
        monitor.start(queue: monitorQueue)
        isMonitoringStarted = true

        // Wait for initial connection status check with timeout
        await waitForInitialConnectionCheck()
    }

    private func waitForInitialConnectionCheck() async {
        // Wait up to 5 seconds for initial connection status
        let timeout = Task {
            try? await Task.sleep(for: .seconds(5))
            await self.setInitialConnectionCheckCompleted()
        }

        while !initialConnectionCheckCompleted {
            try? await Task.sleep(for: .milliseconds(100))
            if timeout.isCancelled {
                break
            }
        }

        timeout.cancel()
    }

    private func setInitialConnectionCheckCompleted() async {
        initialConnectionCheckCompleted = true
    }

    private func updateConnectionStatus(path: NWPath) async {
        let wasConnected = isConnected
        isConnected = path.status == .satisfied
        getConnectionType(path)

        // Mark initial check as completed
        if !initialConnectionCheckCompleted {
            initialConnectionCheckCompleted = true
        }

        // Only post notification if status actually changed
        if wasConnected != isConnected {
            await MainActor.run {
                NotificationCenter.default.post(name: .networkStatusChanged, object: nil)
            }
        }
    }

    func stopMonitoring() {
        guard isMonitoringStarted else { return }
        monitor.cancel()
        isMonitoringStarted = false
        initialConnectionCheckCompleted = false
    }

    private func getConnectionType(_ path: NWPath) {
        if path.usesInterfaceType(.wifi) {
            connectionType = .wifi
        }
        else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
        }
        else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = .ethernet
        }
        else {
            connectionType = .unknown
        }
    }

    // Perform network request using Result type rather than throws
    func performRequest<T: Decodable>(
        urlString: String,
        method: String = "GET",
        body: Data? = nil,
        headers: [String: String]? = nil,
        decoder: JSONDecoder = JSONDecoder()
    ) async -> Result<T, NetworkError> {

        // Ensure monitoring is started before making requests
        if !isMonitoringStarted {
            await startMonitoring()
        }

        return await attemptRequest(
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

        // For autostart scenarios, give network more time to initialize
        if !initialConnectionCheckCompleted {
            let waitResult = await waitForConnection(timeoutSeconds: 10)
            if case .failure = waitResult {
                return .failure(.networkUnavailable)
            }
        }

        // Check network availability with enhanced verification
        if !isConnected {
            // For autostart, do an additional connectivity check
            let connectivityResult = await checkActualConnectivity()
            if case .failure = connectivityResult {
                // Wait for network to become available
                let waitResult = await waitForConnection(timeoutSeconds: 15)
                if case .failure = waitResult {
                    return .failure(.networkUnavailable)
                }
            }
        }

        // Validate URL
        guard let url = URL(string: urlString) else {
            return .failure(.invalidURL)
        }

        // Setup request
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

        // Perform network request
        let dataResult: Result<(Data, HTTPURLResponse), NetworkError>

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(.invalidResponse)
            }

            dataResult = .success((data, httpResponse))
        }
        catch let urlError as URLError {
            // Map URLErrors to NetworkErrors
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

            // Handle retry
            if attempt < maxRetryAttempts {
                // Calculate exponential backoff time
                let delaySeconds = min(pow(2.0, Double(attempt)), 60.0)

                // Use a standard Task.sleep without try
                do {
                    try await Task.sleep(for: .seconds(delaySeconds))
                }
                catch {
                    return .failure(.taskCancelled)
                }

                // Retry
                return await attemptRequest(
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

        // Process response
        switch dataResult {
            case .success((let data, let httpResponse)):
                // Check status code
                guard (200 ... 299).contains(httpResponse.statusCode) else {
                    // Retry on 5xx server errors (transient issues)
                    if (500 ... 599).contains(httpResponse.statusCode) && attempt < maxRetryAttempts {
                        let delaySeconds = min(pow(2.0, Double(attempt)), 60.0)
                        trace.debug("Server error \(httpResponse.statusCode), retrying in \(delaySeconds)s (attempt \(attempt)/\(maxRetryAttempts))")

                        do {
                            try await Task.sleep(for: .seconds(delaySeconds))
                        }
                        catch {
                            return .failure(.taskCancelled)
                        }

                        return await attemptRequest(
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

                // Decode response
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

    // Add a method to actually test connectivity beyond just monitor status
    private func checkActualConnectivity() async -> Result<Void, NetworkError> {
        // Try to connect to a reliable endpoint to verify actual connectivity
        guard let url = URL(string: "https://www.apple.com/library/test/success.html") else {
            return .failure(.invalidURL)
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 10
        request.httpMethod = "HEAD"  // Use HEAD to minimize data usage

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

    // Wait for network connection using Result type with proper Swift 6 concurrency
    private func waitForConnection(timeoutSeconds: Double) async -> Result<Void, NetworkError> {
        if isConnected {
            // Double-check with actual connectivity test
            return await checkActualConnectivity()
        }

        // Use async/await pattern with actor for safe state management
        return await withCheckedContinuation { continuation in
            let connectionMonitor = NWPathMonitor()
            let monitorQueue = DispatchQueue(label: "ConnectionWaitMonitor")

            // Use actor to manage completion state safely
            let connectionWaiter = ConnectionWaiter()

            // Create a task for the timeout
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

                            // Verify actual connectivity before reporting success
                            let connectivityResult = await self.checkActualConnectivity()
                            continuation.resume(returning: connectivityResult)
                        }
                    }
                }
            }
        }
    }

    // Perform network request returning raw Data (without JSON decoding)
    func performDataRequest(
        urlString: String,
        method: String = "GET",
        body: Data? = nil,
        headers: [String: String]? = nil
    ) async -> Result<Data, NetworkError> {

        // Ensure monitoring is started before making requests
        if !isMonitoringStarted {
            await startMonitoring()
        }

        return await attemptDataRequest(
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

        // For autostart scenarios, give network more time to initialize
        if !initialConnectionCheckCompleted {
            let waitResult = await waitForConnection(timeoutSeconds: 10)
            if case .failure = waitResult {
                return .failure(.networkUnavailable)
            }
        }

        // Check network availability with enhanced verification
        if !isConnected {
            // For autostart, do an additional connectivity check
            let connectivityResult = await checkActualConnectivity()
            if case .failure = connectivityResult {
                // Wait for network to become available
                let waitResult = await waitForConnection(timeoutSeconds: 15)
                if case .failure = waitResult {
                    return .failure(.networkUnavailable)
                }
            }
        }

        // Validate URL
        guard let url = URL(string: urlString) else {
            return .failure(.invalidURL)
        }

        // Setup request
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

        // Perform network request
        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(.invalidResponse)
            }

            // Check status code
            guard (200 ... 299).contains(httpResponse.statusCode) else {
                // Retry on 5xx server errors (transient issues)
                if (500 ... 599).contains(httpResponse.statusCode) && attempt < maxRetryAttempts {
                    let delaySeconds = min(pow(2.0, Double(attempt)), 60.0)
                    trace.debug("Server error \(httpResponse.statusCode), retrying in \(delaySeconds)s (attempt \(attempt)/\(maxRetryAttempts))")

                    do {
                        try await Task.sleep(for: .seconds(delaySeconds))
                    }
                    catch {
                        return .failure(.taskCancelled)
                    }

                    return await attemptDataRequest(
                        urlString: urlString,
                        method: method,
                        body: body,
                        headers: headers,
                        attempt: attempt + 1
                    )
                }
                return .failure(.serverError(statusCode: httpResponse.statusCode))
            }

            // Return raw data without decoding
            return .success(data)
        }
        catch let urlError as URLError {
            // Map URLErrors to NetworkErrors
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

            // Handle retry
            if attempt < maxRetryAttempts {
                // Calculate exponential backoff time
                let delaySeconds = min(pow(2.0, Double(attempt)), 60.0)

                // Use a standard Task.sleep without try
                do {
                    try await Task.sleep(for: .seconds(delaySeconds))
                }
                catch {
                    return .failure(.taskCancelled)
                }

                // Retry
                return await attemptDataRequest(
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

/**
 * Actor that manages the completion state for network connection waiting.
 *
 * This actor prevents race conditions when multiple concurrent tasks are waiting
 * for network connectivity. It ensures that only one task can "claim" the completion
 * state, preventing duplicate continuation resumptions that would cause runtime crashes.
 *
 * ## Usage Pattern:
 * ```swift
 * let waiter = ConnectionWaiter()
 * let didComplete = await waiter.tryComplete()
 * if didComplete {
 *     // This task won the race and should handle the completion
 *     continuation.resume(returning: result)
 * }
 * // If didComplete is false, another task already handled completion
 * ```
 *
 * ## Why This Design:
 * - **Thread Safety**: Actor isolation prevents data races on the `isCompleted` flag
 * - **Race Condition Prevention**: Only the first caller gets `true`, others get `false`
 * - **Swift 6 Compliance**: Eliminates shared mutable state in concurrent contexts
 * - **Crash Prevention**: Prevents multiple `continuation.resume()` calls that cause crashes
 */
private actor ConnectionWaiter {
    /// Tracks whether completion has already been claimed by a task
    private var isCompleted = false

    /// Attempts to claim the completion state atomically.
    ///
    /// This method implements a "test-and-set" operation that's safe for concurrent access.
    /// Only the first caller will receive `true`, indicating they should handle the completion.
    /// Subsequent callers receive `false`, indicating completion was already handled.
    ///
    /// - Returns: `true` if this call successfully claimed completion, `false` if already completed
    ///
    /// ## Implementation Details:
    /// The method checks the current state and atomically updates it if not already completed.
    /// This prevents the race condition where multiple tasks might think they need to
    /// resume the same continuation.
    ///
    /// ## Example Race Condition This Prevents:
    /// ```
    /// // WITHOUT this actor (problematic):
    /// var hasResumed = false  // Shared mutable state
    ///
    /// // Task 1: Checks hasResumed (false), sets to true, calls continuation.resume()
    /// // Task 2: Checks hasResumed (might still be false), sets to true, calls continuation.resume()
    /// // Result: CRASH - continuation resumed twice
    ///
    /// // WITH this actor (safe):
    /// // Task 1: Calls tryComplete() -> returns true, handles completion
    /// // Task 2: Calls tryComplete() -> returns false, does nothing
    /// // Result: Safe - only one task handles completion
    /// ```
    func tryComplete() -> Bool {
        // If already completed, return false (another task already handled it)
        guard !isCompleted else {
            return false
        }

        // Atomically claim completion
        isCompleted = true
        return true
    }
}

// Notification extension
extension Notification.Name {
    static let networkStatusChanged = Notification.Name("networkStatusChanged")
}

import Foundation

public class ProcessManager: Identifiable, LocationManagerDelegate {
    public let id = UUID()
    public static let shared = ProcessManager()

    private let locationManager = LocationManager()
    private var location: Location?

    private let updateInterval: TimeInterval = 60
    private var subscriptions: [ProcessSubscription] = []
    private var subscribers: [UUID: any ProcessRefreshable] = [:]
    private var hasPerformedInitialRefresh: Bool = false

    private init() {
        self.locationManager.delegate = self

        // Wait for network to be ready before starting timer
        Task {
            await waitForNetworkReady()
            startUpdateTimer()
        }
    }

    private func waitForNetworkReady() async {
        // Ensure NetworkManager is started
        await NetworkManager.shared.startMonitoring()

        // Wait up to 30 seconds for initial network availability
        for _ in 0..<30 {
            let isConnected = await NetworkManager.shared.isConnected
            if isConnected {
                return
            }
            try? await Task.sleep(for: .seconds(1))
        }
        // Continue anyway after timeout
    }

    private func startUpdateTimer() {
        // Timer must be scheduled on main RunLoop to fire properly
        // When called from a Task, we may be on a background thread without an active RunLoop
        DispatchQueue.main.async {
            Timer.scheduledTimer(withTimeInterval: self.updateInterval, repeats: true) { _ in
                self.updateSubscriptions()
            }
        }
    }

    private func updateSubscriptions() {
        trace.debug("updateSubscriptions() timer fired, checking \(self.subscriptions.count) subscriptions")
        for subscription in self.subscriptions {
            subscription.update(timeout: self.updateInterval)
            if subscription.isPending() {
                if let delegate = self.subscribers[subscription.id], let location = self.location {
                    Task.detached {
                        await delegate.refreshData(location: location)
                    }
                }
                subscription.reset()
            }
        }
    }

    public func refreshSubscriptions() {
        if let location = self.location {
            trace.debug("refreshSubscriptions() called, subscribers count: \(self.subscribers.count)")
            for delegate in self.subscribers.values {
                trace.debug("Calling refreshData on subscriber: \(delegate.id)")
                Task {
                    await delegate.refreshData(location: location)
                }
            }
            self.resetSubscriptions()
        }
    }

    public func refreshSubscription(subscriber: any ProcessRefreshable) {
        if let location = self.location {
            if let delegate = self.subscribers[subscriber.id] {
                Task {
                    await delegate.refreshData(location: location)
                }
            }
        }
    }

    private func resetSubscriptions() {
        for subscription in self.subscriptions {
            subscription.reset()
        }
    }

    func locationManager(didUpdateLocation location: Location) {
        trace.debug("ProcessManager received location update: \(location.latitude), \(location.longitude)")
        self.location = location

        // Only perform initial refresh once, when we first get a location
        // Subsequent location updates don't trigger refreshes - the timer handles those
        if !hasPerformedInitialRefresh {
            hasPerformedInitialRefresh = true
            trace.debug("Performing initial data refresh with location")
            self.refreshSubscriptions()
        } else {
            trace.debug("Ignoring location update (initial refresh already performed)")
        }
    }

    func add(subscriber: any ProcessRefreshable, timeout: TimeInterval) {
        self.subscriptions.append(ProcessSubscription(id: subscriber.id, timeout: timeout * 60))
        self.subscribers[subscriber.id] = subscriber
    }

    func remove(subscriber: any ProcessRefreshable) {
        self.subscriptions.removeAll { $0.id == id }
        self.subscribers.removeValue(forKey: subscriber.id)
    }
}

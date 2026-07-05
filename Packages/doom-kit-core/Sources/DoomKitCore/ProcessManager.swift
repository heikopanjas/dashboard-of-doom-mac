import Foundation

public actor ProcessManager: Identifiable {
    public let id = UUID()
    public static let shared = ProcessManager()

    private let dependencies: ProcessRuntimeDependencies
    private let updateInterval: TimeInterval = 60
    private var location: Location?
    private var subscriptions: [UUID: ProcessSubscription] = [:]
    private var hasPerformedInitialRefresh = false
    private var schedulingTask: Task<Void, Never>?

    public init(dependencies: ProcessRuntimeDependencies = .default) {
        self.dependencies = dependencies
    }

    public func start() -> Void {
        if self.schedulingTask != nil {
            return
        }
        self.schedulingTask = Task {
            await self.dependencies.waitUntilReady()
            await self.runSchedulingLoop()
        }
    }

    public func stop() -> Void {
        self.schedulingTask?.cancel()
        self.schedulingTask = nil
    }

    public func updateLocation(_ location: Location) async -> Void {
        self.dependencies.logger.debug(
            "ProcessManager received location update: \(location.latitude), \(location.longitude)"
        )
        self.location = location

        if self.hasPerformedInitialRefresh == false {
            self.hasPerformedInitialRefresh = true
            self.dependencies.logger.debug("Performing initial data refresh with location")
            await self.refreshSubscriptions()
        }
        else {
            self.dependencies.logger.debug("Ignoring location update (initial refresh already performed)")
        }
    }

    public func add(subscription: ProcessSubscription) -> Void {
        self.subscriptions[subscription.id] = subscription
    }

    public func remove(subscriberId: UUID) -> Void {
        self.subscriptions.removeValue(forKey: subscriberId)
    }

    public func refreshSubscriptions() async -> Void {
        if let location = self.location {
            self.dependencies.logger.debug(
                "refreshSubscriptions() called, subscribers count: \(self.subscriptions.count)"
            )
            for subscription in self.subscriptions.values {
                self.dependencies.logger.debug("Calling refresh on subscription: \(subscription.id)")
                await subscription.refresh(location)
            }
            self.resetSubscriptions()
        }
    }

    public func refreshSubscription(subscriberId: UUID) async -> Void {
        if let location = self.location {
            if let subscription = self.subscriptions[subscriberId] {
                await subscription.refresh(location)
            }
        }
    }

    private func resetSubscriptions() -> Void {
        for subscriptionId in self.subscriptions.keys {
            self.subscriptions[subscriptionId]?.reset()
        }
    }

    private func runSchedulingLoop() async -> Void {
        while Task.isCancelled == false {
            try? await Task.sleep(for: .seconds(self.updateInterval))
            if Task.isCancelled == true {
                break
            }
            await self.updateSubscriptions()
        }
    }

    private func updateSubscriptions() async -> Void {
        self.dependencies.logger.debug(
            "updateSubscriptions() timer fired, checking \(self.subscriptions.count) subscriptions"
        )
        guard let location = self.location else {
            return
        }
        for subscriptionId in self.subscriptions.keys {
            guard var subscription = self.subscriptions[subscriptionId] else {
                continue
            }
            subscription.update(tick: self.updateInterval)
            if subscription.isPending() == true {
                await subscription.refresh(location)
                subscription.reset()
            }
            self.subscriptions[subscriptionId] = subscription
        }
    }
}

import DoomKitCore
import Foundation
import Testing

private actor RefreshCounter {
    private(set) var count = 0

    func increment() {
        self.count += 1
    }
}

private actor ReadyGate {
    private(set) var readyCount = 0

    func markReady() {
        self.readyCount += 1
    }
}

private final class MessageBox: @unchecked Sendable {
    private let lock = NSLock()
    private var messages: [String] = []

    func append(_ message: String) {
        self.lock.lock()
        self.messages.append(message)
        self.lock.unlock()
    }

    var snapshot: [String] {
        self.lock.lock()
        defer { self.lock.unlock() }
        return self.messages
    }
}

@Test
func processRuntimeDependenciesDefaultIsNoOp() async {
    let dependencies = ProcessRuntimeDependencies.default
    await dependencies.waitUntilReady()
    dependencies.logger.debug("noop")
    dependencies.logger.info("noop")
    dependencies.logger.warning("noop")
    dependencies.logger.error("noop")
}

@Test
func processLoggerCapturesMessages() {
    let box = MessageBox()
    let logger = ProcessLogger(
        debug: { message in
            box.append(message)
        }
    )

    logger.debug("hello")

    #expect(box.snapshot == ["hello"])
}

@Test
func processManagerCallsWaitUntilReadyOnStart() async {
    let gate = ReadyGate()
    let dependencies = ProcessRuntimeDependencies(
        waitUntilReady: {
            await gate.markReady()
        }
    )
    let manager = ProcessManager(dependencies: dependencies)

    await manager.start()
    try? await Task.sleep(for: .milliseconds(50))

    #expect(await gate.readyCount == 1)
    await manager.stop()
}

@Test
func processManagerAddAndRemoveSubscriber() async {
    let counter = RefreshCounter()
    let subscriberId = UUID()
    let manager = ProcessManager()
    let subscription = ProcessSubscription(
        id: subscriberId,
        timeout: 60,
        refresh: { _ in
            await counter.increment()
        }
    )

    await manager.add(subscription: subscription)
    await manager.remove(subscriberId: subscriberId)
    await manager.updateLocation(Location(latitude: 52.0, longitude: 13.0))

    #expect(await counter.count == 0)
}

@Test
func processManagerInitialLocationTriggersRefresh() async {
    let counter = RefreshCounter()
    let manager = ProcessManager()
    await manager.add(
        subscription: ProcessSubscription(
            id: UUID(),
            timeout: 60,
            refresh: { _ in
                await counter.increment()
            }
        )
    )

    await manager.updateLocation(Location(latitude: 52.0, longitude: 13.0))
    #expect(await counter.count == 1)

    await manager.updateLocation(Location(latitude: 53.0, longitude: 14.0))
    #expect(await counter.count == 1)
}

@Test
func processManagerRefreshSingleSubscription() async {
    let firstCounter = RefreshCounter()
    let secondCounter = RefreshCounter()
    let firstId = UUID()
    let secondId = UUID()
    let manager = ProcessManager()

    await manager.add(
        subscription: ProcessSubscription(
            id: firstId,
            timeout: 60,
            refresh: { _ in
                await firstCounter.increment()
            }
        )
    )
    await manager.add(
        subscription: ProcessSubscription(
            id: secondId,
            timeout: 60,
            refresh: { _ in
                await secondCounter.increment()
            }
        )
    )

    let location = Location(latitude: 52.0, longitude: 13.0)
    await manager.updateLocation(location)
    await manager.refreshSubscription(subscriberId: secondId)

    #expect(await firstCounter.count == 1)
    #expect(await secondCounter.count == 2)
}

@Test
func processManagerStopCancelsSchedulingTask() async {
    let gate = ReadyGate()
    let dependencies = ProcessRuntimeDependencies(
        waitUntilReady: {
            await gate.markReady()
        }
    )
    let manager = ProcessManager(dependencies: dependencies)

    await manager.start()
    await manager.stop()
    await manager.start()
    try? await Task.sleep(for: .milliseconds(50))

    #expect(await gate.readyCount == 2)
    await manager.stop()
}

@Test
func processManagerLogsLocationUpdate() async {
    let box = MessageBox()
    let dependencies = ProcessRuntimeDependencies(
        logger: ProcessLogger(
            debug: { message in
                box.append(message)
            }
        )
    )
    let manager = ProcessManager(dependencies: dependencies)

    await manager.updateLocation(Location(latitude: 49.5, longitude: 8.4))

    #expect(box.snapshot.contains(where: { $0.contains("49.5") && $0.contains("8.4") }))
}

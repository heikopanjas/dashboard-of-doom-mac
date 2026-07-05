import DoomKitCore
import Foundation
import Observation

@Observable
open class ProcessDataPresenter: ProcessPresenter, ProcessRefreshProtocol {
    private let fetchSensor: @Sendable (Location) async throws -> ProcessSensor?
    private let renderSnapshot: @Sendable (ProcessSensor) throws -> ProcessPresentationSnapshot
    private let logError: @Sendable (String) -> Void
    private let onSensorPublished: (@Sendable (UUID, Location?) -> Void)?

    public init(
        fetchSensor: @escaping @Sendable (Location) async throws -> ProcessSensor?,
        renderSnapshot: @escaping @Sendable (ProcessSensor) throws -> ProcessPresentationSnapshot,
        logError: @escaping @Sendable (String) -> Void = { _ in },
        onSensorPublished: (@Sendable (UUID, Location?) -> Void)? = nil
    ) {
        self.fetchSensor = fetchSensor
        self.renderSnapshot = renderSnapshot
        self.logError = logError
        self.onSensorPublished = onSensorPublished
    }

    public func refreshData(location: Location) async {
        do {
            if let sensor = try await self.fetchSensor(location) {
                let snapshot = try self.renderSnapshot(sensor)
                await self.publish(sensor: sensor, snapshot: snapshot)
            }
        }
        catch {
            self.logError(error.localizedDescription)
        }
    }

    private func publish(sensor: ProcessSensor, snapshot: ProcessPresentationSnapshot) async {
        self.apply(sensor: sensor, snapshot: snapshot)
        self.onSensorPublished?(self.id, sensor.location)
    }
}

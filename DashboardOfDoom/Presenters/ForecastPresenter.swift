import DoomKitProcess
import DoomKitLocation
import SwiftUI

@Observable class ForecastPresenter: ProcessPresenter, ProcessRefreshable {
    private let processController = ForecastController()

    init() {
        super.init(coordinator: AppProcess.shared)
        let processManager = AppProcess.shared
        let interval = UserDefaults.standard.integer(forKey: "weatherRefreshInterval")
        processManager.add(subscriber: self, timeout: TimeInterval(interval > 0 ? interval : 5))
    }

    func refreshData(location: Location) async -> Void {
        do {
            if let sensor = try await processController.refreshData(for: location).first {
                try Task.checkCancellation()
                let transformer = ForecastTransformer()
                try transformer.renderData(sensor: sensor)
                try Task.checkCancellation()
                self.publishData(sensor: sensor, transformer: transformer)
            }
        }
        catch is CancellationError { return }
        catch {
            guard Task.isCancelled == false else { return }
            trace.error("Error refreshing data: %@", error.localizedDescription)
        }
    }

    @MainActor func publishData(sensor: ProcessSensor, transformer: ForecastTransformer) -> Void {
        self.sensor = sensor
        self.timestamp = sensor.timestamp

        self.measurements = transformer.measurements
        self.current = transformer.current
        self.faceplate = transformer.faceplate
        self.range = transformer.range
        self.trend = transformer.trend
    }
}

import SwiftUI

@Observable class ForecastPresenter: ProcessPresenter, ProcessRefreshable {
    private let processController = ForecastController()
    private let processTransformer = ForecastTransformer()

    override init() {
        super.init()
        let processManager = ProcessManager.shared
        let interval = UserDefaults.standard.integer(forKey: "weatherRefreshInterval")
        processManager.add(subscriber: self, timeout: TimeInterval(interval > 0 ? interval : 5))
    }

    func refreshData(location: Location) async -> Void {
        do {
            if let sensor = try await processController.refreshData(for: location).first {
                try self.processTransformer.renderData(sensor: sensor)
                await self.publishData(sensor: sensor)
            }
        }
        catch {
            trace.error("Error refreshing data: %@", error.localizedDescription)
        }
    }

    @MainActor func publishData(sensor: ProcessSensor) async -> Void {
        self.sensor = sensor
        self.timestamp = sensor.timestamp

        self.measurements = self.processTransformer.measurements
        self.current = self.processTransformer.current
        self.faceplate = self.processTransformer.faceplate
        self.range = self.processTransformer.range
        self.trend = self.processTransformer.trend
    }
}

import SwiftUI

@Observable class RadiationPresenter: ProcessPresenter, ProcessRefreshable {
    private let processController = RadiationController()
    private let processTransformer = RadiationTransformer()

    override init() {
        super.init()
        let processManager = ProcessManager.shared
        let interval = UserDefaults.standard.integer(forKey: "radiationRefreshInterval")
        processManager.add(subscriber: self, timeout: TimeInterval(interval > 0 ? interval : 15))
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

        if UserDefaults.standard.bool(forKey: "showRadiation") == true {
        MapPresenter.shared.updateRegion(for: self.id, with: sensor.location)
    }
        else {
            MapPresenter.shared.updateRegion(remove: self.id)
        }
    }
}

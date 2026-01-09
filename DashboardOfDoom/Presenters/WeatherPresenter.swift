import CoreLocation
import MapKit
import SwiftUI

@Observable class WeatherPresenter: ProcessPresenter, ProcessRefreshable {
    private let processController = WeatherController()
    private let processTransformer = WeatherTransformer()

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

        MapPresenter.shared.updateRegion(for: self.id, with: sensor.location)
//        if UserDefaults.standard.bool(forKey: "showWeather") == true {
//            MapPresenter.shared.updateRegion(for: self.id, with: sensor.location)
//        }
//        else {
//            MapPresenter.shared.updateRegion(remove: self.id)
//        }
    }
}

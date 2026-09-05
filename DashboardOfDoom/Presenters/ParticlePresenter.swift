import DoomKitTools
import DoomKitProcess
import DoomKitLocation
import SwiftUI

@Observable class ParticlePresenter: ProcessPresenter, ProcessRefreshable {
    private let processController = ParticleController()

    init() {
        super.init(coordinator: AppProcess.shared)
        let processManager = AppProcess.shared
        let interval = UserDefaults.standard.integer(forKey: "particleRefreshInterval")
        processManager.add(subscriber: self, timeout: TimeInterval(interval > 0 ? interval : 30))
    }

    func refreshData(location: Location) async -> Void {
        do {
            if let sensor = try await processController.refreshData(for: location).first {
                try Task.checkCancellation()
                let transformer = ParticleTransformer()
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

    @MainActor func publishData(sensor: ProcessSensor, transformer: ParticleTransformer) -> Void {
        self.sensor = sensor
        self.timestamp = sensor.timestamp
        self.measurements = transformer.measurements
        self.current = transformer.current
        self.faceplate = transformer.faceplate
        self.range = transformer.range
        self.trend = transformer.trend

        if UserDefaults.standard.bool(forKey: "showParticles") == true {
        MapPresenter.shared.updateRegion(for: self.id, with: sensor.location)
    }
        else {
            MapPresenter.shared.updateRegion(remove: self.id)
        }
    }
}

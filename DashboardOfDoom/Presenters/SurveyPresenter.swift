import DoomKitTools
import DoomKitProcess
import DoomKitLocation
import Foundation
import SwiftUI

@Observable class SurveyPresenter: ProcessPresenter, ProcessRefreshable {
    private let controller = SurveyController()

    init() {
        super.init(coordinator: AppProcess.shared)
        trace.debug("SurveyPresenter init() called, ID: \(self.id)")
        let processManager = AppProcess.shared
        let interval = UserDefaults.standard.integer(forKey: "surveyRefreshInterval")
        processManager.add(subscriber: self, timeout: TimeInterval(interval > 0 ? interval : 360))
    }

    func gradient(selector: ProcessSelector) -> LinearGradient {
        switch selector {
            case .survey(.fascists):
                return Gradient.fascists
            case .survey(.afd):
                return Gradient.fascists
            case .survey(.bsw):
                return Gradient.clowns
            case .survey(.clowns):
                return Gradient.clowns
            case .survey(.fdp):
                return Gradient.clowns
            case .survey(.freie_waehler):
                return Gradient.clowns
            case .survey(.cducsu):
                return Gradient.fascists
            case .survey(.cdu):
                return Gradient.fascists
            case .survey(.csu):
                return Gradient.fascists
            case .survey(.spd):
                return Gradient.spd
            case .survey(.gruene):
                return Gradient.gruene
            case .survey(.linke):
                return Gradient.linke
            case .survey(.sonstige):
                return Gradient.sonstige
            default:
                return Gradient.linear
        }
    }

    func refreshData(location: Location) async -> Void {
        trace.debug("SurveyPresenter.refreshData() called, ID: \(self.id)")
        do {
            if let sensor = try await controller.refreshData(for: location).first {
                try Task.checkCancellation()
                let transformer = SurveyTransformer()
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

    @MainActor func publishData(sensor: ProcessSensor, transformer: SurveyTransformer) -> Void {
        self.sensor = sensor
        self.timestamp = sensor.timestamp
        self.measurements = transformer.measurements
        self.current = transformer.current
        self.faceplate = transformer.faceplate
        self.range = transformer.range
        self.trend = transformer.trend

        if UserDefaults.standard.bool(forKey: "showElectionPolls") == true {
        MapPresenter.shared.updateRegion(for: self.id, with: sensor.location)
    }
            else {
                MapPresenter.shared.updateRegion(remove: self.id)
            }
        }
}

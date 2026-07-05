import DoomKitCore
import Foundation
import Observation

@MainActor
@Observable
open class ProcessPresenter {
    public let id = UUID()
    public var sensor: ProcessSensor?
    public var measurements: [ProcessSelector: [ProcessValue<Dimension>]] = [:]
    public var timestamp: Date?

    public var current: [ProcessSelector: ProcessValue<Dimension>] = [:]
    public var faceplate: [ProcessSelector: String] = [:]
    public var range: [ProcessSelector: ClosedRange<Double>] = [:]
    public var trend: [ProcessSelector: String] = [:]

    public init() {}

    public var label: String {
        return self.sensor?.customData?.string(for: "label") ?? "<Unknown>"
    }

    public var icon: String {
        return self.sensor?.customData?.string(for: "icon") ?? "questionmark.circle"
    }

    public var name: String {
        return self.sensor?.name ?? "<Unknown>"
    }

    public var location: Location {
        return self.sensor?.location ?? Location(latitude: 0.0, longitude: 0.0)
    }

    public var placemark: String {
        return self.sensor?.placemark ?? "<Unknown>"
    }

    public func apply(sensor: ProcessSensor, snapshot: ProcessPresentationSnapshot) {
        self.sensor = sensor
        self.timestamp = sensor.timestamp
        self.measurements = snapshot.measurements
        self.current = snapshot.current
        self.faceplate = snapshot.faceplate
        self.range = snapshot.range
        self.trend = snapshot.trend
    }

    public func isAvailable(selector: ProcessSelector, threshold: Double = 0.0) -> Bool {
        if let measurements = self.measurements[selector] {
            if measurements.isEmpty == false {
                for measurement in measurements where measurement.quality != .unknown {
                    if measurement.value.value > threshold {
                        return true
                    }
                }
            }
        }
        return false
    }
}

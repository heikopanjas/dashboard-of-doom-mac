#if DEBUG
import DoomKitLocation
import DoomKitProcess
import Foundation

/// Deterministic, offline UI-test data. Only enabled by an explicit Debug launch argument.
enum IOSPreviewData {
    static var isEnabled: Bool {
        return ProcessInfo.processInfo.arguments.contains("--ui-fixture")
    }

    static var pointCount: Int {
        return ProcessInfo.processInfo.arguments.contains("--poi-10000") == true ? 10_000 : 2_000
    }

    static func points(category: PointOfInterestCategory) -> [PointOfInterest] {
        guard let categoryIndex = PointOfInterestCategory.allCases.firstIndex(of: category) else { return [] }
        var result: [PointOfInterest] = []
        for index in stride(from: categoryIndex, to: Self.pointCount, by: PointOfInterestCategory.allCases.count) {
            let latitude = 52.51889 + Double((index * 37) % 1000 - 500) / 20_000
            let longitude = 13.36528 + Double((index * 61) % 1000 - 500) / 12_000
            result.append(
                PointOfInterest(
                    category: category, elementType: "node", elementID: Int64(index), name: "Fixture \(index)",
                    location: Location(latitude: latitude, longitude: longitude)))
        }
        return result
    }

    @MainActor
    static func populate(_ runtime: IOSAppRuntime) {
        let entries: [(ProcessPresenter, ProcessSelector, Dimension, Double, String)] = [
            (runtime.weather, .weather(.temperature), UnitTemperature.celsius, 22, "thermometer"),
            (runtime.forecast, .forecast(.temperature), UnitTemperature.celsius, 22, "cloud.sun"),
            (runtime.covid, .covid(.incidence), UnitIncidence.casesPer100k, 12.3, "cross.case"),
            (runtime.levels, .water(.level), UnitLength.meters, 2.73, "water.waves"),
            (runtime.radiation, .radiation(.total), UnitRadiation.microsieverts, 0.08, "atom"),
            (runtime.particles, .particle(.pm10), UnitConcentrationMass.microgramsPerCubicMeter, 18, "aqi.medium"),
            (runtime.surveys, .survey(.fascists), UnitPercentage.percent, 20, "chart.bar")
        ]
        for (index, entry) in entries.enumerated() {
            let (presenter, selector, unit, value, icon) = entry
            let date = Date.now
            let location = Location(latitude: 52.51889 + Double(index % 3) * 0.012, longitude: 13.36528 + Double(index / 3) * 0.015)
            let measurements = (0 ..< 48).map { hour in
                return ProcessValue<Dimension>(
                    value: Measurement(value: value * (1 + 0.1 * sin(Double(hour))), unit: unit),
                    quality: .good, timestamp: date.addingTimeInterval(Double(hour - 24) * 3600))
            }
            presenter.sensor = ProcessSensor(
                name: "HKW fixture", location: location, placemark: "HKW, Berlin",
                customData: ["icon": icon, "label": "HKW"], measurements: [selector: measurements], timestamp: date)
            presenter.timestamp = date
            presenter.measurements = [selector: measurements]
            presenter.current = [selector: measurements[24]]
            presenter.faceplate = [selector: String(format: "%.2f %@", value, unit.symbol)]
            presenter.range = [selector: 0 ... max(value * 1.5, 1)]
            presenter.trend = [selector: "arrow.right"]
            if presenter !== runtime.forecast { MapPresenter.shared.updateRegion(for: presenter.id, with: location) }
        }
    }
}
#endif

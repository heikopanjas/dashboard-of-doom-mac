import DoomKitCore
import DoomKitUI
import Foundation
import Testing

private final class CaptureBox<T>: @unchecked Sendable {
    var value: T

    init(_ value: T) {
        self.value = value
    }
}

@Test
@MainActor
func processPresenterApplyCopiesSnapshotFields() {
    let presenter = ProcessPresenter()
    let selector = ProcessSelector.weather(.temperature)
    let sensor = ProcessSensor(
        name: "Test Sensor",
        location: Location(latitude: 52.0, longitude: 13.0),
        placemark: nil,
        customData: ProcessMetadata(["label": "Berlin", "icon": "cloud"]),
        measurements: [
            selector: [
                ProcessValue(
                    value: Measurement(value: 20, unit: UnitTemperature.celsius),
                    quality: .good,
                    timestamp: Date()
                )
            ]
        ],
        timestamp: Date()
    )
    let measurement = sensor.measurements[selector]!.first!
    let snapshot = ProcessPresentationSnapshot(
        measurements: sensor.measurements,
        current: [selector: measurement],
        faceplate: [selector: "20°C"],
        range: [selector: 10 ... 30],
        trend: [selector: "arrow.up.forward.circle"],
        metadata: sensor.customData ?? [:]
    )

    presenter.apply(sensor: sensor, snapshot: snapshot)

    #expect(presenter.label == "Berlin")
    #expect(presenter.icon == "cloud")
    #expect(presenter.name == "Test Sensor")
    #expect(presenter.isAvailable(selector: selector) == true)
}

@Test
@MainActor
func processDataPresenterRefreshPublishesSnapshot() async {
    let location = Location(latitude: 52.0, longitude: 13.0)
    let sensor = ProcessSensor(
        name: "Weather",
        location: location,
        measurements: [:],
        timestamp: Date()
    )
    let snapshot = ProcessPresentationSnapshot(
        measurements: [:],
        current: [:],
        faceplate: [.weather(.temperature): "21°C"],
        range: [:],
        trend: [:],
        metadata: [:]
    )
    let publishedId = CaptureBox<UUID?>(nil)
    let publishedLocation = CaptureBox<Location?>(nil)

    let presenter = WeatherPresenter(
        fetchSensor: { _ in sensor },
        renderSnapshot: { _ in snapshot },
        onSensorPublished: { id, published in
            publishedId.value = id
            publishedLocation.value = published
        }
    )

    await presenter.refreshData(location: location)

    #expect(presenter.faceplate[.weather(.temperature)] == "21°C")
    #expect(publishedId.value == presenter.id)
    #expect(publishedLocation.value == location)
}

@Test
@MainActor
func processDataPresenterLogsFetchErrors() async {
    let loggedMessages = CaptureBox<[String]>([])
    let presenter = ForecastPresenter(
        fetchSensor: { _ in throw URLError(.badURL) },
        renderSnapshot: { _ in
            ProcessPresentationSnapshot(
                measurements: [:],
                current: [:],
                faceplate: [:],
                range: [:],
                trend: [:],
                metadata: [:]
            )
        },
        logError: { message in
            loggedMessages.value.append(message)
        }
    )

    await presenter.refreshData(location: Location(latitude: 0, longitude: 0))

    #expect(loggedMessages.value.isEmpty == false)
}

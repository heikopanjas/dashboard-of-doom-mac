import DoomKitCore
import Foundation
import Testing

@testable import DoomKitProviders

@Test
func weatherTransformerRendersSnapshotFromSensor() throws {
    let sensor = ProcessSensor(
        name: "Weather",
        location: Location(latitude: 52.0, longitude: 13.0),
        measurements: [
            .weather(.temperature): [
                ProcessValue(
                    value: Measurement(value: 21.5, unit: UnitTemperature.celsius),
                    quality: .good,
                    timestamp: Date()
                )
            ]
        ],
        timestamp: Date()
    )

    let snapshot = try WeatherTransformer().render(sensor: sensor)

    #expect(snapshot.current[.weather(.temperature)]?.value.value == 21.5)
    #expect(snapshot.faceplate[.weather(.temperature)]?.contains("21.5") == true)
}

@Test
func movingAverageSmoothsValues() {
    let values: [ProcessValue<Dimension>] = [
        ProcessValue(value: Measurement(value: 10, unit: UnitTemperature.celsius), quality: .good, timestamp: Date()),
        ProcessValue(value: Measurement(value: 20, unit: UnitTemperature.celsius), quality: .good, timestamp: Date()),
        ProcessValue(value: Measurement(value: 30, unit: UnitTemperature.celsius), quality: .good, timestamp: Date())
    ]

    let smoothed = movingAverage(data: values, windowSize: 2)

    #expect(smoothed.count == 3)
    #expect(smoothed[1].value.value == 15)
    #expect(smoothed[2].value.value == 25)
}

@Test
func movingAverageReturnsEmptyForEmptyInput() {
    #expect(movingAverage(data: [], windowSize: 3).isEmpty)
}

@Test
func processTransformerTrendDetectsIncrease() throws {
    let now = Date()
    let earlier = now.addingTimeInterval(-3600)
    let sensor = ProcessSensor(
        name: "Trend",
        location: Location(latitude: 52.0, longitude: 13.0),
        measurements: [
            .weather(.temperature): [
                ProcessValue(
                    value: Measurement(value: 10, unit: UnitTemperature.celsius),
                    quality: .good,
                    timestamp: earlier
                ),
                ProcessValue(
                    value: Measurement(value: 15, unit: UnitTemperature.celsius),
                    quality: .good,
                    timestamp: now
                )
            ]
        ],
        timestamp: now
    )

    let snapshot = try ProcessTransformer().render(sensor: sensor)

    #expect(snapshot.trend[.weather(.temperature)] == "arrow.up.forward.circle")
}

import DoomKitCore
import DoomKitTools
import Foundation

open class ProcessTransformer: ProcessTransformerProtocol {
    public init() {}

    public func render(sensor: ProcessSensor) throws -> ProcessPresentationSnapshot {
        let measurements = sensor.measurements
        let current = renderCurrent(measurements: measurements)
        let faceplate = renderFaceplate(current: current)
        let range = renderRange(measurements: measurements)
        let trend = renderTrend(measurements: measurements)
        return ProcessPresentationSnapshot(
            measurements: measurements,
            current: current,
            faceplate: faceplate,
            range: range,
            trend: trend,
            metadata: sensor.customData ?? [:]
        )
    }

    open func renderCurrent(measurements: [ProcessSelector: [ProcessValue<Dimension>]]) -> [ProcessSelector: ProcessValue<Dimension>] {
        var current: [ProcessSelector: ProcessValue<Dimension>] = [:]
        for (selector, values) in measurements {
            current[selector] = values.last(where: { ($0.timestamp <= Date.now) && ($0.quality == .good) })
        }
        return current
    }

    open func renderFaceplate(current: [ProcessSelector: ProcessValue<Dimension>]) -> [ProcessSelector: String] {
        var faceplate: [ProcessSelector: String] = [:]
        for (selector, current) in current {
            faceplate[selector] = String(format: "%.2f%@", current.value.value, current.value.unit.symbol)
        }
        return faceplate
    }

    open func renderRange(measurements: [ProcessSelector: [ProcessValue<Dimension>]]) -> [ProcessSelector: ClosedRange<Double>] {
        var scale: [ProcessSelector: ClosedRange<Double>] = [:]
        for (selector, values) in measurements {
            scale[selector] = (values.map({ $0.value }).min()?.value ?? 0.0) ... (values.map({ $0.value }).max()?.value ?? 0.0)
        }
        return scale
    }

    open func renderTrend(measurements: [ProcessSelector: [ProcessValue<Dimension>]]) -> [ProcessSelector: String] {
        var trend: [ProcessSelector: String] = [:]
        for (selector, values) in measurements {
            trend[selector] = "questionmark.circle"
            if let current = values.last(where: { ($0.timestamp <= Date.now) && ($0.quality == .good) }) {
                if let past = values.last(where: { $0.timestamp < current.timestamp }) {
                    if past.value < current.value {
                        trend[selector] = "arrow.up.forward.circle"
                    }
                    else if past.value > current.value {
                        trend[selector] = "arrow.down.forward.circle"
                    }
                    else {
                        trend[selector] = "arrow.right.circle"
                    }
                }
            }
        }
        return trend
    }
}

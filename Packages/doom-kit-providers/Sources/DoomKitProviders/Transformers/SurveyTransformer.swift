import DoomKitCore
import DoomKitTools
import Foundation

public final class SurveyTransformer: ProcessTransformer {
    public override init() {
        super.init()
    }

    public override func renderCurrent(measurements: [ProcessSelector: [ProcessValue<Dimension>]]) -> [ProcessSelector: ProcessValue<Dimension>] {
        var current: [ProcessSelector: ProcessValue<Dimension>] = [:]
        for (selector, values) in measurements {
            current[selector] = values.last(where: { $0.timestamp <= Date.now })
        }
        return current
    }

    public override func renderFaceplate(current: [ProcessSelector: ProcessValue<Dimension>]) -> [ProcessSelector: String] {
        var faceplate: [ProcessSelector: String] = [:]
        for (selector, current) in current {
            faceplate[selector] = String(
                format: "\(MathematicalSymbols.mathematicalBoldCapitalNu.rawValue):%.0f%@", current.value.value, current.value.unit.symbol)
        }
        return faceplate
    }

    public override func renderRange(measurements: [ProcessSelector: [ProcessValue<Dimension>]]) -> [ProcessSelector: ClosedRange<Double>] {
        var scale: [ProcessSelector: ClosedRange<Double>] = [:]
        for (selector, _) in measurements {
            scale[selector] = 0.0 ... 100.0
        }
        return scale
    }

    public override func renderTrend(measurements: [ProcessSelector: [ProcessValue<Dimension>]]) -> [ProcessSelector: String] {
        var trend: [ProcessSelector: String] = [:]
        for (selector, values) in measurements {
            trend[selector] = "questionmark.circle"
            if let current = values.last(where: { ($0.timestamp <= Date.now) }) {
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

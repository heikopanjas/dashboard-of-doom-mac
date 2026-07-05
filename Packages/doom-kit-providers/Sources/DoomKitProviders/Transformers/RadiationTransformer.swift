import DoomKitCore
import DoomKitTools
import Foundation

public final class RadiationTransformer: ProcessTransformer {
    public override init() {
        super.init()
    }

    public override func renderFaceplate(current: [ProcessSelector: ProcessValue<Dimension>]) -> [ProcessSelector: String] {
        var faceplate: [ProcessSelector: String] = [:]
        for (selector, current) in current {
            switch selector {
                case .radiation:
                    faceplate[selector] = String(
                        format: "\(MathematicalSymbols.mathematicalBoldCapitalGamma.rawValue): %.3f%@", current.value.value,
                        current.value.unit.symbol)
                default:
                    faceplate[selector] = "\(MathematicalSymbols.mathematicalBoldCapitalGamma.rawValue):n/a"
            }
        }
        return faceplate
    }

    public override func renderRange(measurements: [ProcessSelector: [ProcessValue<Dimension>]]) -> [ProcessSelector: ClosedRange<Double>] {
        var scale: [ProcessSelector: ClosedRange<Double>] = [:]
        for (selector, values) in measurements {
            scale[selector] = 0.0 ... (values.map({ $0.value }).max()?.value ?? 0.0) * 1.67
        }
        return scale
    }
}

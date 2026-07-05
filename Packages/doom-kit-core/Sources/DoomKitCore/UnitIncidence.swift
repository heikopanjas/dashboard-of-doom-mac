import Foundation

public class UnitIncidence: Dimension, @unchecked Sendable {
    public static let casesPer100k = UnitIncidence(
        symbol: "\u{2081}\u{2080}\u{2080}\u{2096}",
        converter: UnitConverterLinear(coefficient: 1.0)
    )

    public static let casesPer1000k = UnitIncidence(
        symbol: "\u{2081}\u{2080}\u{2080}\u{2080}\u{2096}",
        converter: UnitConverterLinear(coefficient: 0.1)
    )

    override public class func baseUnit() -> Self {
        return casesPer100k as! Self
    }
}

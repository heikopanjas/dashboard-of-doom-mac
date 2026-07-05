import Foundation

public class UnitPercentage: Dimension, @unchecked Sendable {
    public static let percent = UnitPercentage(
        symbol: "%",
        converter: UnitConverterLinear(coefficient: 1.0)
    )

    public static let permille = UnitPercentage(
        symbol: "‰",
        converter: UnitConverterLinear(coefficient: 0.1)
    )

    override public class func baseUnit() -> Self {
        return percent as! Self
    }
}



import Foundation

public enum RoundingStrategy: Sendable {
    case previousQuarterHour
    case nextQuarterHour
    case previousHour
    case nextHour
    case lastDayChange
    case lastUTCDayChange
}

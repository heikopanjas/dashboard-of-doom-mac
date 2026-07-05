import Foundation

/// Represents the interval between time series points
enum TimeSeriesInterval {
    case quarterHourly
    case hourly
    case daily
    case custom(TimeInterval)

    var interval: TimeInterval {
        switch self {
            case .quarterHourly: return 15 * 60
            case .hourly: return 3600
            case .daily: return 24 * 3600
            case .custom(let interval): return interval
        }
    }
}

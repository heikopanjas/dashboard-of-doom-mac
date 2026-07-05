import Foundation

/// ARIMA prediction result
struct ARIMAPrediction {
    let forecasts: [TimeSeriesPoint]
    let confidenceIntervals: [(lower: Double, upper: Double)]
}

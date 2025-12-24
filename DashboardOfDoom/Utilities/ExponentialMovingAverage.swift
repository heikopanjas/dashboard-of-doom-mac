import Foundation

func exponentialMovingAverage(data: [ProcessValue<Dimension>], alpha: Double) -> [ProcessValue<Dimension>] {
    guard data.isEmpty == false else { return [] }

    var smoothed: [ProcessValue<Dimension>] = []

    let unit = data[0].value.unit
    var previousValue = data[0].value.value

    smoothed.append(
        ProcessValue(
            value: Measurement(value: previousValue, unit: unit),
            customData: data[0].customData,
            quality: data[0].quality,
            timestamp: data[0].timestamp
        ))

    for i in 1 ..< data.count {
        let current = data[i]
        let currentValue = current.value.value

        let ema = alpha * currentValue + (1 - alpha) * previousValue
        previousValue = ema

        smoothed.append(
            ProcessValue(
                value: Measurement(value: ema, unit: unit),
                customData: current.customData,
                quality: current.quality,
                timestamp: current.timestamp
            ))
    }

    return smoothed
}



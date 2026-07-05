import DoomKitCore
import DoomKitTools
import Foundation

/// Applies Gaussian smoothing to the `value` field of ProcessValue elements,
/// preserving all other metadata.
func gaussianSmoothing<T: Dimension>(data: [ProcessValue<T>], windowSize: Int = 5, sigma: Double = 1.0) -> [ProcessValue<T>] {
    guard data.isEmpty == false else { return [] }
    let count = data.count
    let radius = windowSize / 2

    // Precompute Gaussian weights
    let weights: [Double] = (0 ..< windowSize).map { i in
        let x = Double(i - radius)
        return exp(-x * x / (2 * sigma * sigma))
    }

    // Smooth each ProcessValue in place
    var smoothed: [ProcessValue<T>] = []
    for i in 0 ..< count {
        var weightedSum = 0.0
        var localWeightSum = 0.0
        let unit = data[i].value.unit

        for j in -radius ... radius {
            let index = i + j
            if index >= 0 && index < count {
                let neighbor = data[index].value.converted(to: unit)
                let weight = weights[j + radius]
                weightedSum += neighbor.value * weight
                localWeightSum += weight
            }
        }

        let smoothedValue = weightedSum / localWeightSum;
        let smoothedMeasurement = Measurement(value: smoothedValue > 0.0 ? smoothedValue : 0.0, unit: unit)

        // Create new ProcessValue with smoothed value, preserving other fields
        let original = data[i]
        let smoothedProcessValue = ProcessValue(
            value: smoothedMeasurement,
            customData: original.customData,
            quality: original.quality,
            timestamp: original.timestamp
        )
        smoothed.append(smoothedProcessValue)
    }

    return smoothed
}



import DoomKitCore
import Foundation

public struct LocationAnalysis {
    let isInside: Bool
    let nearestPoint: Location?
    let distance: Double

    var statusMessage: String {
        if isInside {
            return "🚨 Inside warning area"
        }
        else if distance < 1000 {
            return "⚠️ \(Int(distance))m from warning area"
        }
        else {
            return "✅ \(String(format: "%.1f", distance/1000))km from warning area"
        }
    }
}

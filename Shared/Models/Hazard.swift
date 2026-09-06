import DoomKitLocation
import Foundation

class Hazard: Identifiable {
    let id: String
    let headline: String
    let description: String
    let severity: String
    let timestamp: Date
    var location: Location?
    var placemark: String?

    init(id: String, headline: String, description: String, severity: String, timestamp: Date) {
        self.id = id
        self.headline = headline
        self.description = description
        self.severity = severity
        self.timestamp = timestamp
    }
}


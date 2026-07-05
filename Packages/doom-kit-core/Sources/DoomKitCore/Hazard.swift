import Foundation

public class Hazard: Identifiable, @unchecked Sendable {
    public let id: String
    public let headline: String
    public let description: String
    public let severity: String
    public let timestamp: Date
    public var location: Location?
    public var placemark: String?

    public init(id: String, headline: String, description: String, severity: String, timestamp: Date) {
        self.id = id
        self.headline = headline
        self.description = description
        self.severity = severity
        self.timestamp = timestamp
    }
}

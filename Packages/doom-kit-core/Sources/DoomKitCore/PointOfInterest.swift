import Foundation

public class PointOfInterest: Identifiable, @unchecked Sendable {
    public let id = UUID()
    public let name: String
    public let location: Location

    public init(name: String, location: Location) {
        self.name = name
        self.location = location
    }
}

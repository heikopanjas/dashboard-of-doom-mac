import Foundation

public struct Location: Equatable, Hashable, Sendable {
    public let latitude: Double
    public let longitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

public func isPointInPolygon(point: Location, polygon: [Location]) -> Bool {
    guard polygon.count >= 3 else {
        return false
    }

    let x = point.longitude
    let y = point.latitude
    var inside = false

    var j = polygon.count - 1
    for i in 0 ..< polygon.count {
        let xi = polygon[i].longitude
        let yi = polygon[i].latitude
        let xj = polygon[j].longitude
        let yj = polygon[j].latitude

        if ((yi > y) != (yj > y)) && (x < (xj - xi) * (y - yi) / (yj - yi) + xi) {
            inside.toggle()
        }
        j = i
    }
    return inside
}

import CoreLocation
import Foundation

/// Ray casting algorithm to determine if a point lies within a polygon
/// - Parameters:
///   - point: The point to test (CLLocationCoordinate2D)
///   - polygon: Array of CLLocationCoordinate2D representing the polygon vertices
/// - Returns: Bool indicating whether the point is inside the polygon
func isPointInPolygon(point: CLLocationCoordinate2D, polygon: [CLLocationCoordinate2D]) -> Bool {
    guard polygon.count >= 3 else { return false }

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

/// Ray casting algorithm to determine if a point lies within a polygon
/// - Parameters:
///   - point: The point to test (Location)
///   - polygon: Array of Location representing the polygon vertices
/// - Returns: Bool indicating whether the point is inside the polygon
func isPointInPolygon(point: Location, polygon: [Location]) -> Bool {
    guard polygon.count >= 3 else { return false }

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

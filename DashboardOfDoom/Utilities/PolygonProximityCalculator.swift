import DoomKitProcess
import DoomKitLocation
import Foundation
import CoreLocation

// Your Location type
//public struct Location: Equatable, Hashable {
//    public let latitude: Double
//    public let longitude: Double
//
//    public var coordinate: CLLocationCoordinate2D {
//        return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
//    }
//
//    public init(latitude: Double, longitude: Double) {
//        self.latitude = latitude
//        self.longitude = longitude
//    }
//}

// MARK: - Location Extension for Distance Calculations
extension Location {
    /// Calculate distance in meters between two locations using Haversine formula
    func distance(to location: Location) -> Double {
        let location1 = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let location2 = CLLocation(latitude: location.latitude, longitude: location.longitude)
        return location1.distance(from: location2)
    }

    /// Calculate squared distance (faster for comparisons, no need for sqrt)
    func squaredDistance(to location: Location) -> Double {
        let deltaLat = self.latitude - location.latitude
        let deltaLon = self.longitude - location.longitude
        return deltaLat * deltaLat + deltaLon * deltaLon
    }

    /// Convert to CLLocationCoordinate2D for compatibility
    var clLocationCoordinate2D: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

// MARK: - Nearest Point Calculator
class PolygonProximityCalculator {

    /// Find the nearest point on a polygon's perimeter from a given location
    /// - Parameters:
    ///   - location: The reference point (assumed to be outside the polygon)
    ///   - polygon: Array of Location objects representing the polygon vertices
    /// - Returns: The nearest Location on the polygon's perimeter and the distance in meters
    static func nearestPointOnPolygon(from location: Location,
                                      to polygon: [Location]) -> (point: Location, distance: Double)? {
        guard polygon.count >= 3 else { return nil }

        var nearestPoint = polygon[0]
        var minDistance = Double.greatestFiniteMagnitude

        // Check each edge of the polygon
        for i in 0..<polygon.count {
            let startVertex = polygon[i]
            let endVertex = polygon[(i + 1) % polygon.count] // Wrap around to first vertex

            let closestPointOnEdge = nearestPointOnLineSegment(
                point: location,
                lineStart: startVertex,
                lineEnd: endVertex
            )

            let distance = location.distance(to: closestPointOnEdge)

            if distance < minDistance {
                minDistance = distance
                nearestPoint = closestPointOnEdge
            }
        }

        return (point: nearestPoint, distance: minDistance)
    }

    /// Find the nearest point on a line segment from a given point
    /// - Parameters:
    ///   - point: The reference point
    ///   - lineStart: Start of the line segment
    ///   - lineEnd: End of the line segment
    /// - Returns: The nearest point on the line segment
    static func nearestPointOnLineSegment(point: Location,
                                          lineStart: Location,
                                          lineEnd: Location) -> Location {

        let A = point.latitude - lineStart.latitude
        let B = point.longitude - lineStart.longitude
        let C = lineEnd.latitude - lineStart.latitude
        let D = lineEnd.longitude - lineStart.longitude

        let dot = A * C + B * D
        let lenSq = C * C + D * D

        // Handle degenerate case where line segment is actually a point
        guard lenSq > 0 else { return lineStart }

        let param = dot / lenSq

        let result: Location

        if param < 0 {
            // Closest point is the start of the line segment
            result = lineStart
        } else if param > 1 {
            // Closest point is the end of the line segment
            result = lineEnd
        } else {
            // Closest point is somewhere along the line segment
            result = Location(
                latitude: lineStart.latitude + param * C,
                longitude: lineStart.longitude + param * D
            )
        }

        return result
    }

    /// Fast version using squared distances (good for performance when you only need to compare distances)
    /// - Parameters:
    ///   - location: The reference point
    ///   - polygon: Array of Location objects representing the polygon vertices
    /// - Returns: The nearest Location and squared distance (not in meters)
    static func nearestPointOnPolygonFast(from location: Location,
                                          to polygon: [Location]) -> (point: Location, squaredDistance: Double)? {
        guard polygon.count >= 3 else { return nil }

        var nearestPoint = polygon[0]
        var minSquaredDistance = Double.greatestFiniteMagnitude

        for i in 0..<polygon.count {
            let startVertex = polygon[i]
            let endVertex = polygon[(i + 1) % polygon.count]

            let closestPointOnEdge = nearestPointOnLineSegment(
                point: location,
                lineStart: startVertex,
                lineEnd: endVertex
            )

            let squaredDistance = location.squaredDistance(to: closestPointOnEdge)

            if squaredDistance < minSquaredDistance {
                minSquaredDistance = squaredDistance
                nearestPoint = closestPointOnEdge
            }
        }

        return (point: nearestPoint, squaredDistance: minSquaredDistance)
    }
}

// MARK: - Convenience Extensions
extension PolygonProximityCalculator {

    /// Find multiple nearest points (useful for finding alternative routes or entry points)
    /// - Parameters:
    ///   - location: The reference point
    ///   - polygon: Array of Location objects representing the polygon vertices
    ///   - count: Number of nearest points to return
    /// - Returns: Array of nearest points sorted by distance
    static func nearestPoints(from location: Location,
                              to polygon: [Location],
                              count: Int = 3) -> [(point: Location, distance: Double)] {
        guard polygon.count >= 3 else { return [] }

        var allPoints: [(point: Location, distance: Double)] = []

        // Calculate nearest point on each edge
        for i in 0..<polygon.count {
            let startVertex = polygon[i]
            let endVertex = polygon[(i + 1) % polygon.count]

            let closestPointOnEdge = nearestPointOnLineSegment(
                point: location,
                lineStart: startVertex,
                lineEnd: endVertex
            )

            let distance = location.distance(to: closestPointOnEdge)
            allPoints.append((point: closestPointOnEdge, distance: distance))
        }

        // Sort by distance and return top results
        return Array(allPoints.sorted { $0.distance < $1.distance }.prefix(count))
    }

    /// Check if location is approaching the polygon (within a certain distance threshold)
    /// - Parameters:
    ///   - location: The reference point
    ///   - polygon: Array of Location objects representing the polygon vertices
    ///   - threshold: Distance threshold in meters
    /// - Returns: True if within threshold distance
    static func isApproachingPolygon(location: Location,
                                     polygon: [Location],
                                     threshold: Double = 1000) -> Bool {
        guard let result = nearestPointOnPolygon(from: location, to: polygon) else {
            return false
        }
        return result.distance <= threshold
    }
}

// MARK: - Usage Examples
class ProximityUsageExamples {

    func demonstrateUsage() {
        // Sample polygon (roughly a square in Germany) using your Location type
        let polygon = [
            Location(latitude: 49.8432, longitude: 8.5625),
            Location(latitude: 49.9541, longitude: 8.7244),
            Location(latitude: 49.8709, longitude: 8.7267),
            Location(latitude: 49.7962, longitude: 8.6454)
        ]

        // User's current location (outside the polygon)
        let userLocation = Location(latitude: 49.7500, longitude: 8.4000)

        // Find nearest point
        if let result = PolygonProximityCalculator.nearestPointOnPolygon(from: userLocation, to: polygon) {
            print("Nearest point: lat \(result.point.latitude), lon \(result.point.longitude)")
            print("Distance: \(Int(result.distance)) meters")
        }

        // Check if approaching
        let isApproaching = PolygonProximityCalculator.isApproachingPolygon(
            location: userLocation,
            polygon: polygon,
            threshold: 5000 // 5km
        )
        print("Is approaching warning area: \(isApproaching)")

        // Get multiple nearest points
        let nearestPoints = PolygonProximityCalculator.nearestPoints(from: userLocation, to: polygon, count: 2)
        for (index, result) in nearestPoints.enumerated() {
            print("Option \(index + 1): \(Int(result.distance))m away")
        }
    }

    // Real-world usage in a warning system
    func checkProximityToWarningArea(userLocation: Location,
                                     warningPolygon: [Location]) -> String {
        guard let nearest = PolygonProximityCalculator.nearestPointOnPolygon(from: userLocation, to: warningPolygon) else {
            return "Unable to calculate distance to warning area"
        }

        let distanceKm = nearest.distance / 1000

        if distanceKm < 1 {
            return "⚠️ Very close to warning area (\(Int(nearest.distance))m)"
        } else if distanceKm < 5 {
            return "⚠️ Approaching warning area (\(String(format: "%.1f", distanceKm))km)"
        } else {
            return "Warning area is \(String(format: "%.1f", distanceKm))km away"
        }
    }

    // Complete location analysis (inside check + nearest point)
    func checkLocationStatus(userLocation: Location, warningPolygon: [Location]) -> String {
        let analysis = PolygonProximityCalculator.analyzeLocationRelativeToPolygon(
            location: userLocation,
            polygon: warningPolygon
        )
        return analysis.statusMessage
    }
}

// MARK: - Performance Optimized Version for Real-time Use
class FastPolygonProximity {
    private var lastPolygon: [Location] = []
    private var precomputedEdges: [(start: Location, end: Location)] = []

    /// Precompute polygon edges for faster repeated calculations
    func setPolygon(_ polygon: [Location]) {
        self.lastPolygon = polygon
        self.precomputedEdges = []

        for i in 0..<polygon.count {
            let start = polygon[i]
            let end = polygon[(i + 1) % polygon.count]
            precomputedEdges.append((start: start, end: end))
        }
    }

    /// Fast calculation using precomputed edges
    func nearestPoint(from location: Location) -> (point: Location, distance: Double)? {
        guard !precomputedEdges.isEmpty else { return nil }

        var nearestPoint = precomputedEdges[0].start
        var minDistance = Double.greatestFiniteMagnitude

        for edge in precomputedEdges {
            let closestPointOnEdge = PolygonProximityCalculator.nearestPointOnLineSegment(
                point: location,
                lineStart: edge.start,
                lineEnd: edge.end
            )

            let distance = location.distance(to: closestPointOnEdge)

            if distance < minDistance {
                minDistance = distance
                nearestPoint = closestPointOnEdge
            }
        }

        return (point: nearestPoint, distance: minDistance)
    }
}

// MARK: - Point in Polygon Check (for completeness)
extension PolygonProximityCalculator {

    /// Ray casting algorithm to determine if a point lies within a polygon
    /// - Parameters:
    ///   - point: The point to test (Location)
    ///   - polygon: Array of Location objects representing the polygon vertices
    /// - Returns: Bool indicating whether the point is inside the polygon
    static func isPointInPolygon(point: Location, polygon: [Location]) -> Bool {
        guard polygon.count >= 3 else { return false }

        let x = point.longitude
        let y = point.latitude
        var inside = false

        var j = polygon.count - 1
        for i in 0..<polygon.count {
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

    /// Combined function that checks if inside polygon, and if not, returns nearest point
    /// - Parameters:
    ///   - location: The Location to check
    ///   - polygon: Array of Location objects representing the polygon vertices
    /// - Returns: Status indicating inside/outside and nearest point info
    static func analyzeLocationRelativeToPolygon(location: Location,
                                                 polygon: [Location]) -> LocationAnalysis {
        let isInside = isPointInPolygon(point: location, polygon: polygon)

        if isInside {
            return LocationAnalysis(isInside: true, nearestPoint: nil, distance: 0)
        } else {
            let nearest = nearestPointOnPolygon(from: location, to: polygon)
            return LocationAnalysis(
                isInside: false,
                nearestPoint: nearest?.point,
                distance: nearest?.distance ?? 0
            )
        }
    }
}

// MARK: - Result Type
struct LocationAnalysis {
    let isInside: Bool
    let nearestPoint: Location?
    let distance: Double // in meters, 0 if inside

    var statusMessage: String {
        if isInside {
            return "🚨 Inside warning area"
        } else if distance < 1000 {
            return "⚠️ \(Int(distance))m from warning area"
        } else {
            return "✅ \(String(format: "%.1f", distance/1000))km from warning area"
        }
    }
}

import CoreLocation
import DoomKitCore
import Foundation

public class PolygonProximityCalculator {

    /// Find the nearest point on a polygon's perimeter from a given location
    /// - Parameters:
    ///   - location: The reference point (assumed to be outside the polygon)
    ///   - polygon: Array of Location objects representing the polygon vertices
    /// - Returns: The nearest Location on the polygon's perimeter and the distance in meters
    public static func nearestPointOnPolygon(
        from location: Location,
        to polygon: [Location]
    ) -> (point: Location, distance: Double)? {
        guard polygon.count >= 3 else { return nil }

        var nearestPoint = polygon[0]
        var minDistance = Double.greatestFiniteMagnitude

        // Check each edge of the polygon
        for i in 0 ..< polygon.count {
            let startVertex = polygon[i]
            let endVertex = polygon[(i + 1) % polygon.count]  // Wrap around to first vertex

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
    public static func nearestPointOnLineSegment(
        point: Location,
        lineStart: Location,
        lineEnd: Location
    ) -> Location {

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
        }
        else if param > 1 {
            // Closest point is the end of the line segment
            result = lineEnd
        }
        else {
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
    public static func nearestPointOnPolygonFast(
        from location: Location,
        to polygon: [Location]
    ) -> (point: Location, squaredDistance: Double)? {
        guard polygon.count >= 3 else { return nil }

        var nearestPoint = polygon[0]
        var minSquaredDistance = Double.greatestFiniteMagnitude

        for i in 0 ..< polygon.count {
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
    public static func nearestPoints(
        from location: Location,
        to polygon: [Location],
        count: Int = 3
    ) -> [(point: Location, distance: Double)] {
        guard polygon.count >= 3 else { return [] }

        var allPoints: [(point: Location, distance: Double)] = []

        // Calculate nearest point on each edge
        for i in 0 ..< polygon.count {
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
    public static func isApproachingPolygon(
        location: Location,
        polygon: [Location],
        threshold: Double = 1000
    ) -> Bool {
        guard let result = nearestPointOnPolygon(from: location, to: polygon) else {
            return false
        }
        return result.distance <= threshold
    }
}

extension PolygonProximityCalculator {

    /// Combined function that checks if inside polygon, and if not, returns nearest point
    public static func analyzeLocationRelativeToPolygon(
        location: Location,
        polygon: [Location]
    ) -> LocationAnalysis {
        let isInside = isPointInPolygon(point: location, polygon: polygon)

        if isInside {
            return LocationAnalysis(isInside: true, nearestPoint: nil, distance: 0)
        }
        else {
            let nearest = nearestPointOnPolygon(from: location, to: polygon)
            return LocationAnalysis(
                isInside: false,
                nearestPoint: nearest?.point,
                distance: nearest?.distance ?? 0
            )
        }
    }
}

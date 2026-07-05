import DoomKitCore
import DoomKitTools
import Foundation
import Testing

@Test
func haversineDistanceBetweenSamePointIsZero() {
    let location = Location(latitude: 52.51889, longitude: 13.36528)
    let distance = haversineDistance(location_0: location, location_1: location)

    #expect(distance.value == 0.0)
}

@Test
func haversineDistanceBetweenBerlinAndHouseOfWorldCultures() {
    let berlin = Location(latitude: 52.5200, longitude: 13.4050)
    let house = LocationManager.houseOfWorldCultures
    let distance = haversineDistance(location_0: berlin, location_1: house)

    #expect(distance.value > 1000)
    #expect(distance.value < 5000)
}

@Test
func calculateBoundingBoxIsSymmetricAroundCenter() {
    let center = Location(latitude: 49.0, longitude: 8.0)
    let bounds = calculateBoundingBox(center: center, radiusInMeters: 1000)

    #expect(bounds.minLatitude < center.latitude)
    #expect(bounds.maxLatitude > center.latitude)
    #expect(bounds.minLongitude < center.longitude)
    #expect(bounds.maxLongitude > center.longitude)
}

@Test
func nearestPointOnLineSegmentReturnsEndpointWhenOutsideSegment() {
    let point = Location(latitude: 0.0, longitude: 0.0)
    let start = Location(latitude: 1.0, longitude: 1.0)
    let end = Location(latitude: 2.0, longitude: 2.0)

    let nearest = PolygonProximityCalculator.nearestPointOnLineSegment(
        point: point,
        lineStart: start,
        lineEnd: end
    )

    #expect(nearest == start)
}

@Test
func nearestPointOnPolygonRequiresAtLeastThreeVertices() {
    let point = Location(latitude: 0.0, longitude: 0.0)
    let segment = [
        Location(latitude: 1.0, longitude: 1.0),
        Location(latitude: 2.0, longitude: 2.0)
    ]

    #expect(PolygonProximityCalculator.nearestPointOnPolygon(from: point, to: segment) == nil)
}

@Test
func isPointInPolygonDetectsInsidePoint() {
    let square = [
        Location(latitude: 0.0, longitude: 0.0),
        Location(latitude: 0.0, longitude: 1.0),
        Location(latitude: 1.0, longitude: 1.0),
        Location(latitude: 1.0, longitude: 0.0)
    ]
    let inside = Location(latitude: 0.5, longitude: 0.5)

    #expect(isPointInPolygon(point: inside, polygon: square) == true)
}

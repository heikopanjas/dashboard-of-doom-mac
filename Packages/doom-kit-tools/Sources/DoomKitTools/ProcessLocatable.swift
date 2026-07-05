import DoomKitCore
import Foundation

public protocol ProcessLocatable {
    var location: Location { get }
}

public func sortByDistance<T: ProcessLocatable>(_ items: [T], from location: Location, limit: Int = 0) -> [T] {
    let sortedItems = items.sorted {
        haversineDistance(location_0: location, location_1: $0.location) < haversineDistance(location_0: location, location_1: $1.location)
    }
    if limit > 0 {
        return Array(sortedItems.prefix(limit))
    }
    else {
        return sortedItems
    }
}

public func maxDistance<T: ProcessLocatable>(_ items: [T], from location: Location, limit: Int = 0) -> Measurement<UnitLength> {
    let sorted = sortByDistance(items, from: location, limit: limit)

    guard let farthest = sorted.last else { return Measurement(value: 0.0, unit: UnitLength.meters) }
    return haversineDistance(location_0: location, location_1: farthest.location)
}

public func minDistance<T: ProcessLocatable>(_ items: [T], from location: Location, limit: Int = 0) -> Measurement<UnitLength> {
    let sorted = sortByDistance(items, from: location, limit: limit)

    guard let nearest = sorted.first else { return Measurement(value: 0.0, unit: UnitLength.meters) }
    return haversineDistance(location_0: location, location_1: nearest.location)
}

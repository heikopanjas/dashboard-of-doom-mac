import DoomKitCore
import DoomKitTools
import Foundation

public final class PointOfInterestController {
    private let radius = 6666.67

    public init() {}

    public func fetchPharmacies(location: Location) async -> [PointOfInterest] {
        var pharmacies: [PointOfInterest] = []
        do {
            if let data = try await PointOfInterestService.fetchPharmacies(location: location, radius: self.radius) {
                pharmacies = try Self.parsePointsOfInterest(from: data)
            }
        }
        catch {
            trace.error("Error fetching pharmacies: %@", error.localizedDescription)
        }
        return pharmacies
    }

    public func fetchHospitals(location: Location) async -> [PointOfInterest] {
        var hospitals: [PointOfInterest] = []
        do {
            if let data = try await PointOfInterestService.fetchHospitals(location: location, radius: self.radius) {
                hospitals = try Self.parsePointsOfInterest(from: data)
            }
        }
        catch {
            trace.error("Error fetching hospitals: %@", error.localizedDescription)
        }
        return hospitals
    }

    public func fetchLiquorStores(location: Location) async -> [PointOfInterest] {
        var liquorStores: [PointOfInterest] = []
        do {
            if let data = try await PointOfInterestService.fetchLiquorStores(location: location, radius: self.radius) {
                liquorStores = try Self.parsePointsOfInterest(from: data)
            }
        }
        catch {
            trace.error("Error fetching liquor stores: %@", error.localizedDescription)
        }
        return liquorStores
    }

    public func fetchFuneralDirectors(location: Location) async -> [PointOfInterest] {
        var funeralDirectors: [PointOfInterest] = []
        do {
            if let data = try await PointOfInterestService.fetchFuneralDirectors(location: location, radius: self.radius) {
                funeralDirectors = try Self.parsePointsOfInterest(from: data)
            }
        }
        catch {
            trace.error("Error fetching funeral directors: %@", error.localizedDescription)
        }
        return funeralDirectors
    }

    public func fetchCemeteries(location: Location) async -> [PointOfInterest] {
        var cemeteries: [PointOfInterest] = []
        do {
            if let data = try await PointOfInterestService.fetchCemeteries(location: location, radius: self.radius) {
                cemeteries = try Self.parsePointsOfInterest(from: data)
            }
        }
        catch {
            trace.error("Error fetching cemeteries: %@", error.localizedDescription)
        }
        return cemeteries
    }

    private static func parsePointsOfInterest(from data: Data) throws -> [PointOfInterest] {
        var pointsOfInterest: [PointOfInterest] = []
        if let json = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]) as? [String: Any] {
            if let elements = json["elements"] as? [[String: Any]] {
                for element in elements {
                    if let type = element["type"] as? String {
                        if type == "node" {
                            if let latitude = element["lat"] as? Double, let longitude = element["lon"] as? Double {
                                if let tags = element["tags"] as? [String: Any] {
                                    if let name = tags["name"] as? String {
                                        pointsOfInterest.append(
                                            PointOfInterest(name: name, location: Location(latitude: latitude, longitude: longitude)))
                                    }
                                }
                            }
                        }
                        else if type == "way" {
                            if let center = element["center"] as? [String: Any] {
                                if let latitude = center["lat"] as? Double, let longitude = center["lon"] as? Double {
                                    if let tags = element["tags"] as? [String: Any] {
                                        if let name = tags["name"] as? String {
                                            pointsOfInterest.append(
                                                PointOfInterest(name: name, location: Location(latitude: latitude, longitude: longitude)))
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return pointsOfInterest
    }
}

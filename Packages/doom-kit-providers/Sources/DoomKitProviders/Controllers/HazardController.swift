import DoomKitCore
import DoomKitTools
import Foundation

public final class HazardController {
    public init() {}

    public func fetchHazards(location: Location) async -> [Hazard] {
        var hazards: [Hazard] = []
        do {
            var hazardIds: [String] = []
            if let data = try await HazardService.fetchCivilProtectionHazards() {
                hazardIds.append(contentsOf: try Self.parseCivilProtectionHazardIds(from: data))
            }
            if let data = try await HazardService.fetchWeatherHazards() {
                hazardIds.append(contentsOf: try Self.parseWeatherHazardIds(from: data))
            }
            for hazardId in hazardIds {
                if let data = try await HazardService.fetchHazardDetails(for: hazardId) {
                    if let hazard = try Self.parseHazardDetails(from: data) {
                        if let data = try await HazardService.fetchHazardRegion(for: hazardId) {
                            let region = try Self.parseHazardRegion(from: data)
                            if region.isEmpty == false {
                                if isPointInPolygon(point: location, polygon: region) {
                                    hazard.location = location
                                }
                                else {
                                    if let nearestPoint = PolygonProximityCalculator.nearestPointOnPolygon(from: location, to: region) {
                                        hazard.location = nearestPoint.point
                                    }
                                }
                            }

                            if let nearestLocation = hazard.location {
                                if let placemark = await LocationManager.reverseGeocodeLocation(location: nearestLocation, fullAddress: false) {
                                    hazard.placemark = placemark
                                    hazards.append(hazard)
                                }
                            }
                        }
                    }
                }
                else {
                    trace.error("Failed to fetch hazard details for ID: %@", hazardId)
                }
            }
        }
        catch {
            trace.error("Error fetching hazards: %@", error.localizedDescription)
        }
        hazards.sort { $0.timestamp > $1.timestamp }
        return hazards
    }

    private static func parseCivilProtectionHazardIds(from data: Data) throws -> [String] {
        var ids: [String] = []
        if let json = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]) as? [[String: Any]] {
            for element in json {
                if let id = element["id"] as? String, let type = element["type"] as? String {
                    if type != "Cancel" {
                        ids.append(id)
                    }
                }
            }
        }
        return ids
    }

    private static func parseWeatherHazardIds(from data: Data) throws -> [String] {
        var ids: [String] = []
        if let json = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]) as? [[String: Any]] {
            for element in json {
                if let id = element["id"] as? String, let type = element["type"] as? String {
                    if type != "Cancel" {
                        ids.append(id)
                    }
                }
            }
        }
        return ids
    }

    private static func sanitizeDescription(_ description: String?) -> String {
        guard let description = description else {
            return ""
        }
        return description.replacingOccurrences(of: "<br/>", with: "\n")
    }

    private static func parseHazardDetails(from data: Data) throws -> Hazard? {
        var hazardDetails: Hazard? = nil
        if let json = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]) as? [String: Any] {
            if let id = json["identifier"] as? String {
                if let timestampString = json["sent"] as? String {
                    let formatter = ISO8601DateFormatter()
                    if let timestamp = formatter.date(from: timestampString) {
                        let components = Calendar.current.dateComponents([.day], from: timestamp, to: Date.now)
                        let daysDifference = components.day ?? 0
                        if daysDifference <= 3 {
                            if let infoArray = json["info"] as? [Any], let info = infoArray.first as? [String: Any] {
                                if let headline = info["headline"] as? String {
                                    if let severity = info["severity"] as? String {
                                        if let description = info["description"] as? String {
                                            hazardDetails = Hazard(
                                                id: id,
                                                headline: headline,
                                                description: Self.sanitizeDescription(description),
                                                severity: severity,
                                                timestamp: timestamp
                                            )
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return hazardDetails
    }

    private static func parseHazardRegion(from data: Data) throws -> [Location] {
        var hazardRegion: [Location] = []
        if let json = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]) as? [String: Any] {
            if let features = json["features"] as? [Any], let feature = features.first as? [String: Any] {
                if let geometry = feature["geometry"] as? [String: Any] {
                    if let coordinates = geometry["coordinates"] as? [Any], let points = coordinates.first as? [[Double]] {
                        for point in points where point.count >= 2 {
                            let latitude = point[1]
                            let longitude = point[0]
                            hazardRegion.append(Location(latitude: latitude, longitude: longitude))
                        }
                    }
                }
            }
        }
        return hazardRegion
    }
}

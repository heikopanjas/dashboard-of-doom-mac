import DoomKitServices
import DoomKitTools
import DoomKitProcess
import DoomKitLocation
import Foundation

class HazardController {
    func fetchHazards(location: Location) async -> [Hazard]? {
        var hazards: [Hazard]? = nil
        do {
            var hazardIds: [String] = []
            if let data = try await HazardService.fetchCivilProtectionHazards() {
                if let civilProtectionHazardIds = try Self.parseCivilProtectionHazardIds(from: data) {
                    hazardIds.append(contentsOf: civilProtectionHazardIds)
                }
            }
            if let data = try await HazardService.fetchWeatherHazards() {
                if let weatherHazardIds = try Self.parseWeatherHazardIds(from: data) {
                    hazardIds.append(contentsOf: weatherHazardIds)
                }
            }
            for hazardId in hazardIds {
                if let data = try await HazardService.fetchHazardDetails(for: hazardId) {
                    if let hazard = try Self.parseHazardDetails(from: data) {
                        if let data = try await HazardService.fetchHazardRegion(for: hazardId) {
                            if let region = try Self.parseHazardRegion(from: data) {
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
//                                let distance = haversineDistance(location_0: location, location_1: nearestLocation).converted(to: UnitLength.kilometers)
//                                if distance.value < 167.0 {  // Only include hazards within 100km
                                if let placemark = await GeocodingService.reverseGeocodeLocation(location: nearestLocation, fullAddress: false) {
                                        hazard.placemark = placemark
                                        if hazards == nil {
                                            hazards = [hazard]
                                        }
                                        else {
                                            hazards?.append(hazard)
                                        }
                                    }
//                                }
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
        hazards?.sort { $0.timestamp > $1.timestamp }  // Sort hazards by timestamp, most recent first
        return hazards
    }

    private static func parseCivilProtectionHazardIds(from data: Data) throws -> [String]? {
        var ids: [String]? = nil
        if let json = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]) as? [[String:Any]] {
            for element in json {
                if let id = element["id"] as? String, let type = element["type"] as? String {
                    if type != "Cancel" {
                        if ids == nil {
                            ids = [id]
                        }
                        else {
                            ids?.append(id)
                        }
                    }
                }
            }
        }
        return ids
    }

    private static func parseWeatherHazardIds(from data: Data) throws -> [String]? {
        var ids: [String]? = nil
        if let json = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]) as? [[String:Any]] {
            for element in json {
                if let id = element["id"] as? String, let type = element["type"] as? String {
                    if type != "Cancel" {
                        if ids == nil {
                            ids = [id]
                        }
                        else {
                            ids?.append(id)
                        }
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
        if let json = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]) as? [String:Any] {
            if let id = json["identifier"] as? String {
                if let timestampString = json["sent"] as? String {
                    let formatter = ISO8601DateFormatter()
                    if let timestamp = formatter.date(from: timestampString) {
                        let components = Calendar.current.dateComponents([.day], from: timestamp, to: Date.now)
                        let daysDifference = components.day ?? 0
                        if daysDifference <= 3 { // Only include hazards from the last 3 days
                        if let infoArray = json["info"] as? [Any], let info = infoArray.first as? [String:Any] {
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

    private static func parseHazardRegion(from data: Data) throws -> [Location]? {
        var hazardRegion: [Location]? = nil
        if let json = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]) as? [String:Any] {
            if let features = json["features"] as? [Any], let feature = features.first as? [String:Any] {
                if let geometry = feature["geometry"] as? [String:Any] {
                    if let coordinates = geometry["coordinates"] as? [Any], let points = coordinates.first as? [[Double]] {
                        for point in points {
                            if point.count >= 2 {
                                let latitude = point[1]
                                let longitude = point[0]
                                let location = Location(latitude: latitude, longitude: longitude)
                                if hazardRegion == nil {
                                    hazardRegion = [location]
                                } else {
                                    hazardRegion?.append(location)
                                }
                            }
                        }
                    }
                }
            }
        }
        return hazardRegion
    }
}


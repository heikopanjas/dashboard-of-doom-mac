import DoomKitNetwork
import DoomKitLocation
import Foundation

class LevelService {
    static func fetchStations() async throws -> Data? {
        trace.debug("Fetching level measurements stations...")
        let urlString = "https://www.pegelonline.wsv.de/webservices/rest-api/v2/stations.json"
        let result = await NetworkManager.shared.performDataRequest(urlString: urlString)
        switch result {
            case .success(let data):
        trace.debug("Fetched level measurements stations.")
        return data
            case .failure(let error):
                trace.error("Failed to fetch level measurements stations: \(error.localizedDescription)")
                return nil
        }
    }

    static func fetchWaterways(for location: Location, radius: Double) async throws -> Data? {
        let box = calculateBoundingBox(center: location, radiusInMeters: radius)
        let query = "[out:json][timeout:25][bbox:\(box.minLatitude),\(box.minLongitude),\(box.maxLatitude),\(box.maxLongitude)];(way(around:\(radius),\(location.latitude),\(location.longitude))[\"waterway\"=\"river\"];);out center tags qt;"

        // URL encode the query and construct proper API endpoint
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            trace.error("Failed to encode Overpass query")
            return nil
        }

        let urlString = "https://overpass-api.de/api/interpreter?data=\(encodedQuery)"

        trace.debug("Fetching nearby waterways for location: \(location.latitude), \(location.longitude), radius: \(radius)m")
        trace.debug("Overpass API URL length: \(urlString.count) chars")

        let networkStatus = await NetworkManager.shared.isConnected
        trace.debug("Network status before waterways request: \(networkStatus ? "connected" : "disconnected")")

        let result = await NetworkManager.shared.performDataRequest(urlString: urlString)
        switch result {
            case .success(let data):
                trace.debug("Fetched nearby waterways successfully, data size: \(data.count) bytes")
                return data
            case .failure(let error):
                let networkStatusAfter = await NetworkManager.shared.isConnected
                trace.error("Failed to fetch nearby waterways - Error: \(error)")
                trace.error("  Location: \(location.latitude), \(location.longitude), radius: \(radius)m")
                trace.error("  Network before: \(networkStatus), after: \(networkStatusAfter)")
                trace.error("  URL length: \(urlString.count) chars")
                trace.error("  Query: \(query)")
                return nil
        }
    }

    static func fetchMeasurements(for id: String) async throws -> Data? {
        trace.debug("Fetching water level measurements for station: \(id)")
        let urlString = "https://www.pegelonline.wsv.de/webservices/rest-api/v2/stations/\(id)/W/measurements.json?start=P3D"
        let result = await NetworkManager.shared.performDataRequest(urlString: urlString)
        switch result {
            case .success(let data):
        trace.debug("Fetched water level measurements for station: \(id)")
        return data
            case .failure(let error):
                trace.error("Failed to fetch water level measurements for station: \(id): \(error.localizedDescription)")
                return nil
        }
    }

    static func fetchForecast(for id: String) async throws -> Data? {
        trace.debug("Fetching water level forecast for station: \(id)")
        let urlString = "https://www.pegelonline.wsv.de/webservices/rest-api/v2/stations/\(id)/WV/measurements.json"
        let result = await NetworkManager.shared.performDataRequest(urlString: urlString)
        switch result {
            case .success(let data):
        trace.debug("Fetched water level forecast for station: \(id)")
        return data
            case .failure(let error):
                trace.error("Failed to fetch water level forecast for station: \(id): \(error.localizedDescription)")
                return nil
        }
    }
}

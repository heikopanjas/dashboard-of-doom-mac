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

        trace.debug("Fetching Fetching nearby waterways...")
        let result = await NetworkManager.shared.performDataRequest(urlString: urlString)
        switch result {
            case .success(let data):
                trace.debug("Fetched Fetching nearby waterways.")
        return data
            case .failure(let error):
                trace.error("Failed to fetch Fetching nearby waterways: \(error.localizedDescription)")
                return nil
        }
    }

    static func fetchMeasurements(for id: String) async throws -> Data? {
        trace.debug("Fetching level measurements...")
        let urlString = "https://www.pegelonline.wsv.de/webservices/rest-api/v2/stations/\(id)/W/measurements.json?start=P3D"
        let result = await NetworkManager.shared.performDataRequest(urlString: urlString)
        switch result {
            case .success(let data):
        trace.debug("Fetched level measurements.")
        return data
            case .failure(let error):
                trace.error("Failed to fetch level measurements: \(error.localizedDescription)")
                return nil
        }
    }

    static func fetchForecast(for id: String) async throws -> Data? {
        trace.debug("Fetching level measurements forecast...")
        let urlString = "https://www.pegelonline.wsv.de/webservices/rest-api/v2/stations/\(id)/WV/measurements.json"
        let result = await NetworkManager.shared.performDataRequest(urlString: urlString)
        switch result {
            case .success(let data):
        trace.debug("Fetched level measurements forecast.")
        return data
            case .failure(let error):
                trace.error("Failed to fetch level measurements forecast: \(error.localizedDescription)")
                return nil
        }
    }
}

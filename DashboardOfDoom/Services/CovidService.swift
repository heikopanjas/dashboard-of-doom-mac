import Foundation

class CovidService {
    static func fetchDistricts(for location: Location, radius: Double) async throws -> Data? {
        let box = calculateBoundingBox(center: location, radiusInMeters: radius)
        let query = "[out:json][timeout:25][bbox:\(box.minLatitude),\(box.minLongitude),\(box.maxLatitude),\(box.maxLongitude)];relation(around:\(radius),\(location.latitude),\(location.longitude))[\"boundary\"=\"administrative\"][\"admin_level\"~\"4|6|7|8|9\"];out center tags qt;"

        // URL encode the query and construct proper API endpoint
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            trace.error("Failed to encode Overpass query")
            return nil
        }

        let urlString = "https://overpass-api.de/api/interpreter?data=\(encodedQuery)"

        trace.debug("Fetching covid districts near location: \(location.latitude), \(location.longitude), radius: \(radius)m")
        trace.debug("Overpass API URL length: \(urlString.count) chars")

        let networkStatus = await NetworkManager.shared.isConnected
        trace.debug("Network status before districts request: \(networkStatus ? "connected" : "disconnected")")

        let result = await NetworkManager.shared.performDataRequest(urlString: urlString)
        switch result {
            case .success(let data):
                trace.debug("Fetched covid districts successfully, data size: \(data.count) bytes")
                return data
            case .failure(let error):
                let networkStatusAfter = await NetworkManager.shared.isConnected
                trace.error("Failed to fetch covid districts - Error: \(error)")
                trace.error("  Location: \(location.latitude), \(location.longitude), radius: \(radius)m")
                trace.error("  Network before: \(networkStatus), after: \(networkStatusAfter)")
                trace.error("  URL length: \(urlString.count) chars")
                trace.error("  Query: \(query)")
                return nil
        }
    }

    static func fetchIncidence(id: String, duration: Double = 100.0) async throws -> Data? {
        trace.debug("Fetching covid incidence for district: \(id)")
        let urlString = "https://api.corona-zahlen.org/districts/\(id)/history/incidence/\(Int(duration))"
        let result = await NetworkManager.shared.performDataRequest(urlString: urlString)
        switch result {
            case .success(let data):
        trace.debug("Fetched covid incidence for district: \(id)")
        return data
            case .failure(let error):
                trace.error("Failed to fetch covid incidence for district: \(id): \(error.localizedDescription)")
                return nil
        }
    }

    static func fetchCases(id: String, duration: Double = 100.0) async throws -> Data? {
        trace.debug("Fetching covid cases for district: \(id)")
        let urlString = "https://api.corona-zahlen.org/districts/\(id)/history/cases/\(Int(duration))"
        let result = await NetworkManager.shared.performDataRequest(urlString: urlString)
        switch result {
            case .success(let data):
        trace.debug("Fetched covid cases for district: \(id)")
        return data
            case .failure(let error):
                trace.error("Failed to fetch covid cases for district: \(id): \(error.localizedDescription)")
                return nil
        }
    }

    static func fetchDeaths(id: String, duration: Double = 100.0) async throws -> Data? {
        trace.debug("Fetching covid deaths for district: \(id)")
        let urlString = "https://api.corona-zahlen.org/districts/\(id)/history/deaths/\(Int(duration))"
        let result = await NetworkManager.shared.performDataRequest(urlString: urlString)
        switch result {
            case .success(let data):
        trace.debug("Fetched covid deaths for district: \(id)")
        return data
            case .failure(let error):
                trace.error("Failed to fetch covid deaths for district: \(id): \(error.localizedDescription)")
                return nil
        }
    }

    static func fetchRecovered(id: String, duration: Double = 100.0) async throws -> Data? {
        trace.debug("Fetching covid recovered for district: \(id)")
        let urlString = "https://api.corona-zahlen.org/districts/\(id)/history/recovered/\(Int(duration))"
        let result = await NetworkManager.shared.performDataRequest(urlString: urlString)
        switch result {
            case .success(let data):
        trace.debug("Fetched covid recovered for district: \(id)")
        return data
            case .failure(let error):
                trace.error("Failed to fetch covid recovered for district: \(id): \(error.localizedDescription)")
                return nil
        }
    }
}

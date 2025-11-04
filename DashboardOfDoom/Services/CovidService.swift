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

        trace.debug("Fetching covid measurement districts...")
        let result = await NetworkManager.shared.performDataRequest(urlString: urlString)
        switch result {
            case .success(let data):
        trace.debug("Fetched covid measurement districts.")
        return data
            case .failure(let error):
                trace.error("Failed to fetch covid measurement districts: \(error.localizedDescription)")
                return nil
        }
    }

    static func fetchIncidence(id: String, duration: Double = 100.0) async throws -> Data? {
        trace.debug("Fetching covid incidence measurements...")
        let urlString = "https://api.corona-zahlen.org/districts/\(id)/history/incidence/\(Int(duration))"
        let result = await NetworkManager.shared.performDataRequest(urlString: urlString)
        switch result {
            case .success(let data):
        trace.debug("Fetched covid incidence measurements.")
        return data
            case .failure(let error):
                trace.error("Failed to fetch covid incidence measurements: \(error.localizedDescription)")
                return nil
        }
    }

    static func fetchCases(id: String, duration: Double = 100.0) async throws -> Data? {
        trace.debug("Fetching covid cases measurements...")
        let urlString = "https://api.corona-zahlen.org/districts/\(id)/history/cases/\(Int(duration))"
        let result = await NetworkManager.shared.performDataRequest(urlString: urlString)
        switch result {
            case .success(let data):
        trace.debug("Fetched covid cases measurements.")
        return data
            case .failure(let error):
                trace.error("Failed to fetch covid cases measurements: \(error.localizedDescription)")
                return nil
        }
    }

    static func fetchDeaths(id: String, duration: Double = 100.0) async throws -> Data? {
        trace.debug("Fetching covid deaths measurements...")
        let urlString = "https://api.corona-zahlen.org/districts/\(id)/history/deaths/\(Int(duration))"
        let result = await NetworkManager.shared.performDataRequest(urlString: urlString)
        switch result {
            case .success(let data):
        trace.debug("Fetched covid deaths measurements.")
        return data
            case .failure(let error):
                trace.error("Failed to fetch covid deaths measurements: \(error.localizedDescription)")
                return nil
        }
    }

    static func fetchRecovered(id: String, duration: Double = 100.0) async throws -> Data? {
        trace.debug("Fetching covid recovered measurements...")
        let urlString = "https://api.corona-zahlen.org/districts/\(id)/history/recovered/\(Int(duration))"
        let result = await NetworkManager.shared.performDataRequest(urlString: urlString)
        switch result {
            case .success(let data):
        trace.debug("Fetched covid recovered measurements.")
        return data
            case .failure(let error):
                trace.error("Failed to fetch covid recovered measurements: \(error.localizedDescription)")
                return nil
        }
    }
}

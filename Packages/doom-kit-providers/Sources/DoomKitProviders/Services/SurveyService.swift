import DoomKitCore
import DoomKitTools
import Foundation

public enum SurveyService {
    static func fetchStates(for location: Location) async throws -> Data? {
        let query = "[out:json][timeout:25];relation(around:10000,\(location.latitude),\(location.longitude))[\"boundary\"=\"administrative\"][\"admin_level\"=\"4\"];out center tags;"

        // URL encode the query and construct proper API endpoint
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            trace.error("Failed to encode Overpass query")
            return nil
        }

        let urlString = "https://overpass-api.de/api/interpreter?data=\(encodedQuery)"

        trace.debug("Fetching federal states...")
        let result = await NetworkManager.shared.performDataRequest(urlString: urlString)
        switch result {
            case .success(let data):
                trace.debug("Fetched federal states.")
        return data
            case .failure(let error):
                trace.error("Failed to fetch federal states: \(error.localizedDescription)")
                return nil
        }
    }

    static func fetchPolls() async throws -> Data? {
        trace.debug("Fetching election polls...")
        let urlString = "https://api.dawum.de"
        let result = await NetworkManager.shared.performDataRequest(urlString: urlString)
        switch result {
            case .success(let data):
                trace.debug("Fetched election polls.")
                return data
            case .failure(let error):
                trace.error("Failed to fetch election polls: \(error.localizedDescription)")
            return nil
        }
    }
}

import Foundation

class HazardService {
    static func fetchCivilProtectionHazards() async throws -> Data? {
        trace.debug("Fetching civil protection hazards...")
        let urlString = "https://nina.api.proxy.bund.dev/api31/mowas/mapData.json"
        let result = await NetworkManager.shared.performDataRequest(urlString: urlString)
        switch result {
            case .success(let data):
                trace.debug("Fetched civil protection hazards.")
                return data
            case .failure(let error):
                trace.error("Failed to fetch civil protection hazards: \(error.localizedDescription)")
                return nil
        }
    }

    static func fetchWeatherHazards() async throws -> Data? {
        trace.debug("Fetching weather hazards...")
        let urlString = "https://nina.api.proxy.bund.dev/api31/dwd/mapData.json"
        let result = await NetworkManager.shared.performDataRequest(urlString: urlString)
        switch result {
            case .success(let data):
                trace.debug("Fetched weather hazards.")
                return data
            case .failure(let error):
                trace.error("Failed to fetch weather hazards: \(error.localizedDescription)")
                return nil
        }
    }

    static func fetchHazardDetails(for alertId: String) async throws -> Data? {
        trace.debug("Fetching hazard details...")
        let urlString = "https://nina.api.proxy.bund.dev/api31/warnings/\(alertId).json"
        let result = await NetworkManager.shared.performDataRequest(urlString: urlString)
        switch result {
            case .success(let data):
                trace.debug("Fetched hazard details.")
                return data
            case .failure(let error):
                trace.error("Failed to fetch hazard details: \(error.localizedDescription)")
                return nil
        }
    }

    static func fetchHazardRegion(for alertId: String) async throws -> Data? {
        trace.debug("Fetching hazard region...")
        let urlString = "https://nina.api.proxy.bund.dev/api31/warnings/\(alertId).geojson"
        let result = await NetworkManager.shared.performDataRequest(urlString: urlString)
        switch result {
            case .success(let data):
                trace.debug("Fetched hazard region.")
                return data
            case .failure(let error):
                trace.error("Failed to fetch hazard region: \(error.localizedDescription)")
                return nil
        }
    }
}

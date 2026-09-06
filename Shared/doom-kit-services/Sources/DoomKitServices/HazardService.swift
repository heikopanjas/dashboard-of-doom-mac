import DoomKitNetwork
import DoomKitTools
import Foundation

public class HazardService {
    public static func fetchCivilProtectionHazards(networkManager: NetworkManager = .shared) async throws -> Data? {
        trace.debug("Fetching civil protection hazards...")
        let urlString = "https://nina.api.proxy.bund.dev/api31/mowas/mapData.json"
        let result = await networkManager.performDataRequest(urlString: urlString)
        switch result {
            case .success(let data):
                trace.debug("Fetched civil protection hazards.")
                return data
            case .failure(let error):
                trace.error("Failed to fetch civil protection hazards: \(error.localizedDescription)")
                return nil
        }
    }

    public static func fetchWeatherHazards(networkManager: NetworkManager = .shared) async throws -> Data? {
        trace.debug("Fetching weather hazards...")
        let urlString = "https://nina.api.proxy.bund.dev/api31/dwd/mapData.json"
        let result = await networkManager.performDataRequest(urlString: urlString)
        switch result {
            case .success(let data):
                trace.debug("Fetched weather hazards.")
                return data
            case .failure(let error):
                trace.error("Failed to fetch weather hazards: \(error.localizedDescription)")
                return nil
        }
    }

    public static func fetchHazardDetails(for alertId: String, networkManager: NetworkManager = .shared) async throws -> Data? {
        trace.debug("Fetching hazard details...")
        let urlString = "https://nina.api.proxy.bund.dev/api31/warnings/\(alertId).json"
        let result = await networkManager.performDataRequest(urlString: urlString)
        switch result {
            case .success(let data):
                trace.debug("Fetched hazard details.")
                return data
            case .failure(let error):
                trace.error("Failed to fetch hazard details: \(error.localizedDescription)")
                return nil
        }
    }

    public static func fetchHazardRegion(for alertId: String, networkManager: NetworkManager = .shared) async throws -> Data? {
        trace.debug("Fetching hazard region...")
        let urlString = "https://nina.api.proxy.bund.dev/api31/warnings/\(alertId).geojson"
        let result = await networkManager.performDataRequest(urlString: urlString)
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

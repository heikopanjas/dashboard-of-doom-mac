import Foundation

class HazardService {
    static func fetchCivilProtectionHazards() async throws -> Data? {
        guard let url = URL(string: "https://nina.api.proxy.bund.dev/api31/mowas/mapData.json") else {
            return nil
        }
        trace.debug("Fetching civil protection hazards...")
        let (data, _) = try await URLSession.shared.dataWithRetry(from: url)
        trace.debug("Fetched civil protection hazards.")
        return data
    }

    static func fetchWeatherHazards() async throws -> Data? {
        guard let url = URL(string: "https://nina.api.proxy.bund.dev/api31/dwd/mapData.json") else {
            return nil
        }
        trace.debug("Fetching weather hazards...")
        let (data, _) = try await URLSession.shared.dataWithRetry(from: url)
        trace.debug("Fetched weather hazards.")
        return data
    }

    static func fetchHazardDetails(for alertId: String) async throws -> Data? {
        guard alertId.isEmpty == false else {
            return nil
        }
        guard let url = URL(string: "https://nina.api.proxy.bund.dev/api31/warnings/\(alertId).json") else {
            return nil
        }
        do {
            trace.debug("Fetching hazard details...")
            let (data, _) = try await URLSession.shared.dataWithRetry(from: url)
            trace.debug("Fetched hazard details.")
            return data
        }
        catch {
            trace.error("Error fetching hazard details: %@", error.localizedDescription)
            return nil
        }
    }

    static func fetchHazardRegion(for alertId: String) async throws -> Data? {
        guard alertId.isEmpty == false else {
            return nil
        }
        guard let url = URL(string: "https://nina.api.proxy.bund.dev/api31/warnings/\(alertId).geojson") else {
            return nil
        }
        do {
            trace.debug("Fetching hazard region...")
            let (data, _) = try await URLSession.shared.dataWithRetry(from: url)
            trace.debug("Fetched hazard bounding box.")
            return data
        }
        catch {
            trace.error("Error fetching hazard region: %@", error.localizedDescription)
            return nil
        }
    }
}

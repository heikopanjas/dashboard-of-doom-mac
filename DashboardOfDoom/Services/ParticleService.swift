import Foundation

class ParticleService {
    static func fetchStations(from: Date, to: Date) async throws -> Data? {
        trace.debug("Fetching particle measurements stations...")
        let hour = Calendar.current.component(.hour, from: from)
        let urlString = "https://www.umweltbundesamt.de/api/air_data/v3/stations/json?use=airquality&lang=en&date_from=\(from.dateString())&time_from=\(hour)&date_to=\(to.dateString())&time_to=\(hour)"
        let result = await NetworkManager.shared.performDataRequest(urlString: urlString)
        switch result {
            case .success(let data):
                trace.debug("Fetched particle measurements stations.")
            return data
            case .failure(let error):
                trace.error("Failed to fetch particle measurements stations: \(error.localizedDescription)")
                return nil
        }
    }

    static func fetchMeasurements(code: String, from: Date, to: Date) async throws -> Data? {
        trace.debug("Fetching particle measurements for station: \(code)")
        let hour = Calendar.current.component(.hour, from: from)
        let urlString = "https://www.umweltbundesamt.de/api/air_data/v3/airquality/json?date_from=\(from.dateString())&time_from=\(hour)&date_to=\(to.dateString())&time_to=\(hour)&station=\(code)"
        let result = await NetworkManager.shared.performDataRequest(urlString: urlString)
        switch result {
            case .success(let data):
            trace.debug("Fetched particle measurements for station: \(code)")
            return data
            case .failure(let error):
                trace.error("Failed to fetch particle measurements for station: \(code): \(error.localizedDescription)")
                return nil
        }
    }

    static func fetchForecasts(code: String, from: Date, to: Date) async throws -> Data? {
        trace.debug("Fetching particle forecast for station: \(code)")
        let hour = Calendar.current.component(.hour, from: from)
        let urlString = "https://www.umweltbundesamt.de/api/air_data/v3/airqualityforecast/json?date_from=\(from.dateString())&time_from=\(hour)&date_to=\(to.dateString())&time_to=\(hour)&station=\(code)"
        let result = await NetworkManager.shared.performDataRequest(urlString: urlString)
        switch result {
            case .success(let data):
                trace.debug("Fetched particle forecast for station: \(code)")
            return data
            case .failure(let error):
                trace.error("Failed to fetch particle forecast for station: \(code): \(error.localizedDescription)")
                return nil
        }
    }
}

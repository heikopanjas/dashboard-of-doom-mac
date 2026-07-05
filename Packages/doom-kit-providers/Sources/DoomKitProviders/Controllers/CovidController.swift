import DoomKitCore
import DoomKitTools
import Foundation

public final class CovidController: ProcessControllerProtocol, Sendable {
    private let measurementDistance: TimeInterval
    private let measurementDuration: Double
    private let forecastDuration: TimeInterval

    public init() {
        self.measurementDistance = 24 * 60 * 60  // 1 day
        self.measurementDuration = 167.0  // 167 days
        self.forecastDuration = Double(Int(self.measurementDuration / 4)) * self.measurementDistance
    }

    public func refreshData(for location: Location) async throws -> [ProcessSensor] {
        var data: [ProcessSensor] = []
        if let district = try await self.fetchDistrict(for: location) {
            var measurements: [ProcessSelector: [ProcessValue<Dimension>]] = [:]

            // Launch all fetches in parallel
            async let incidenceData = self.fetchIncidence(for: district)
            async let casesData = self.fetchCases(for: district)
            async let deathsData = self.fetchDeaths(for: district)
            async let recoveredData = self.fetchRecovered(for: district)

            // Await all results together
            let (incidence, cases, deaths, recovered) = try await (incidenceData, casesData, deathsData, recoveredData)

            if let incidence = incidence {
                var measurement: [ProcessValue<Dimension>] = []
                measurement.append(contentsOf: self.interpolateMeasurements(measurements: incidence, distance: self.measurementDistance))
                measurement.append(contentsOf: self.forecastMeasurements(data: incidence, duration: self.forecastDuration))
                measurements[.covid(.incidence)] = measurement.sorted(by: { $0.timestamp < $1.timestamp })
            }
            if let cases = cases {
                var measurement: [ProcessValue<Dimension>] = []
                measurement.append(contentsOf: self.interpolateMeasurements(measurements: cases, distance: self.measurementDistance))
                measurement.append(contentsOf: self.forecastMeasurements(data: cases, duration: self.forecastDuration))
                measurements[.covid(.cases)] = measurement.sorted(by: { $0.timestamp < $1.timestamp })
            }
            if let deaths = deaths {
                var measurement: [ProcessValue<Dimension>] = []
                measurement.append(contentsOf: self.interpolateMeasurements(measurements: deaths, distance: self.measurementDistance))
                measurement.append(contentsOf: self.forecastMeasurements(data: deaths, duration: self.forecastDuration))
                measurements[.covid(.deaths)] = measurement.sorted(by: { $0.timestamp < $1.timestamp })
            }
            if let recovered = recovered {
                var measurement: [ProcessValue<Dimension>] = []
                measurement.append(contentsOf: self.interpolateMeasurements(measurements: recovered, distance: self.measurementDistance))
                measurement.append(contentsOf: self.forecastMeasurements(data: recovered, duration: self.forecastDuration))
                measurements[.covid(.recovered)] = measurement.sorted(by: { $0.timestamp < $1.timestamp })
            }
            if let placemark = await LocationManager.reverseGeocodeLocation(location: district.location) {
                let sensor = ProcessSensor(
                    name: district.name, location: district.location, placemark: placemark,
                    customData: ProcessMetadata(["name": "COVID-19", "icon": "facemask"]), measurements: measurements, timestamp: Date.now)
                data.append(sensor)
            }
        }
        return data
    }

    struct District: Identifiable, Equatable {
        let id: String
        let name: String
        let location: Location
    }

    private func fetchDistrict(for location: Location) async throws -> District? {
        var nearestDistrict: District? = nil
        if let data = try await CovidService.fetchDistricts(for: location, radius: 30000) {
            if let candidateDistricts: [District] = try await Self.parseDistricts(data: data) {
                var minDistance = Measurement(value: 1000.0, unit: UnitLength.kilometers)  // This is more than the distance from List to Oberstdorf (960km)
                for candidateDistrict in candidateDistricts {
                    let candidateLocation = candidateDistrict.location
                    let distance = haversineDistance(location_0: candidateLocation, location_1: location).converted(to: .kilometers)
                    if distance < minDistance {
                        minDistance = distance
                        nearestDistrict = candidateDistrict
                    }
                }
            }
        }
        return nearestDistrict
    }

    static private func parseDistricts(data: Data) async throws -> [District]? {
        var districts: [District]? = nil
        if let json = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]) as? [String: Any] {
            if let elements = json["elements"] as? [[String: Any]] {
                var nearestDistricts: [District] = []
                for element in elements {
                    if let center = element["center"] as? [String: Any] {
                        if let latitude = center["lat"] as? Double, let longitude = center["lon"] as? Double {
                            if let tags = element["tags"] as? [String: Any] {
                                if let name = tags["name"] as? String {
                                    if let id = tags["de:regionalschluessel"] as? String {
                                        if id.count >= 5 {
                                            let location = Location(latitude: latitude, longitude: longitude)
                                            nearestDistricts.append(District(id: String(id.prefix(5)), name: name, location: location))
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                districts = nearestDistricts
            }
        }
        return districts
    }

    private func fetchIncidence(for district: District) async throws -> [ProcessValue<Dimension>]? {
        var incidence: [ProcessValue<Dimension>]? = nil
        if let data = try await CovidService.fetchIncidence(id: district.id, duration: self.measurementDuration) {
            if let measurements = try Self.parseData(data: data, district: district, tag: "weekIncidence", unit: UnitIncidence.casesPer100k) {
                incidence = measurements
                if let current = Self.nowCast(data: incidence, alpha: 0.33) {
                    incidence?.append(current)
                }
            }
        }
        return incidence
    }

    private func fetchCases(for district: District) async throws -> [ProcessValue<Dimension>]? {
        var incidence: [ProcessValue<Dimension>]? = nil
        if let data = try await CovidService.fetchCases(id: district.id, duration: self.measurementDuration) {
            if let measurements = try Self.parseData(data: data, district: district, tag: "cases", unit: UnitPopulation.people) {
                incidence = measurements
                if let current = Self.nowCast(data: incidence, alpha: 0.33) {
                    incidence?.append(current)
                }
            }
        }
        return incidence
    }

    private func fetchDeaths(for district: District) async throws -> [ProcessValue<Dimension>]? {
        var incidence: [ProcessValue<Dimension>]? = nil
        if let data = try await CovidService.fetchDeaths(id: district.id, duration: self.measurementDuration) {
            if let measurements = try Self.parseData(data: data, district: district, tag: "deaths", unit: UnitPopulation.people) {
                incidence = measurements
                if let current = Self.nowCast(data: incidence, alpha: 0.33) {
                    incidence?.append(current)
                }
            }
        }
        return incidence
    }

    private func fetchRecovered(for district: District) async throws -> [ProcessValue<Dimension>]? {
        var incidence: [ProcessValue<Dimension>]? = nil
        if let data = try await CovidService.fetchRecovered(id: district.id, duration: self.measurementDuration) {
            if let measurements = try Self.parseData(data: data, district: district, tag: "recovered", unit: UnitPopulation.people) {
                incidence = measurements
                if let current = Self.nowCast(data: incidence, alpha: 0.33) {
                    incidence?.append(current)
                }
            }
        }
        return incidence
    }

    static private func parseData(data: Data, district: District, tag: String, unit: Dimension) throws -> [ProcessValue<Dimension>]? {
        var incidence: [ProcessValue<Dimension>]?
        if let json = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]) as? [String: Any] {
            if let data = json["data"] as? [String: Any] {
                if let district = data[district.id] as? [String: Any] {
                    if let history = district["history"] as? [[String: Any]] {
                        for entry in history {
                            if let value = entry[tag] as? Double {
                                if let dateString = entry["date"] as? String {
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                                    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
                                    if let date = dateFormatter.date(from: dateString) {
                                        let newIncidence = ProcessValue<Dimension>(
                                            value: Measurement<Dimension>(value: value, unit: unit), quality: .good,
                                            timestamp: date)
                                        if incidence == nil {
                                            incidence = [newIncidence]
                                        }
                                        else {
                                            incidence?.append(
                                                ProcessValue<Dimension>(
                                                    value: Measurement<Dimension>(value: value, unit: unit), quality: .good,
                                                    timestamp: date))
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return incidence
    }

    private static func nowCast(data: [ProcessValue<Dimension>]?, alpha: Double) -> ProcessValue<Dimension>? {
        guard let data = data, data.count > 0, alpha >= 0.0, alpha <= 1.0 else {
            return nil
        }
        let historicalData = [ProcessValue<Dimension>](data.reversed())
        if let current = historicalData.max(by: { $0.timestamp < $1.timestamp }) {
            if let timestamp = Calendar.current.date(byAdding: .day, value: 1, to: current.timestamp) {
                let value = Self.nowCast(data: historicalData[1].value, previous: historicalData[0].value, alpha: alpha)
                return ProcessValue<Dimension>(value: value, quality: .uncertain, timestamp: timestamp)
            }
        }
        return nil
    }

    private static func nowCast(
        data: Measurement<Dimension>, previous: Measurement<Dimension>, alpha: Double
    ) -> Measurement<Dimension> {
        let value = alpha * data.value + (1 - alpha) * previous.value
        return Measurement<Dimension>(value: value, unit: data.unit)
    }

    private func interpolateMeasurements(measurements: [ProcessValue<Dimension>], distance: TimeInterval) -> [ProcessValue<Dimension>] {
        var interpolatedMeasurement: [ProcessValue<Dimension>] = []
        if let start = measurements.first?.timestamp, let end = measurements.last?.timestamp {
            var current = start
            if var last = measurements.first {
                while current <= end {
                    if let match = measurements.first(where: { $0.timestamp == current }) {
                        last = match
                        interpolatedMeasurement.append(match)
                    }
                    else {
                        interpolatedMeasurement
                            .append(
                                ProcessValue<Dimension>(
                                    value: Measurement(value: last.value.value, unit: last.value.unit), quality: .uncertain,
                                    timestamp: current))
                    }
                    current = current.addingTimeInterval(distance)
                }
            }
        }
        return interpolatedMeasurement
    }

    private func forecastMeasurements(data: [ProcessValue<Dimension>], duration: TimeInterval) -> [ProcessValue<Dimension>] {
        var forecastMeasurements: [ProcessValue<Dimension>] = []
        if data.count > 0 {
            let unit = data[0].value.unit
            let dataPoints = data.map { incidence in
                TimeSeriesPoint(timestamp: incidence.timestamp, value: incidence.value.value)
            }
            let predictor = ARIMAPredictor(parameters: ARIMAParameters(p: 2, d: 1, q: 1), interval: .daily)
            do {
                try predictor.addData(dataPoints)
                let prediction = try predictor.forecast(duration: duration)
                forecastMeasurements = prediction.forecasts.map { forecast in
                    //                    ProcessValue<Dimension>(value: Measurement(value: forecast.value, unit: unit), quality: .uncertain, timestamp: forecast.timestamp)
                    ProcessValue<Dimension>(value: Measurement(value: 0.0, unit: unit), quality: .unknown, timestamp: forecast.timestamp)
                }
            }
            catch {
                trace.error("Forecasting error: %@", error.localizedDescription)
            }
        }
        return forecastMeasurements
    }
}

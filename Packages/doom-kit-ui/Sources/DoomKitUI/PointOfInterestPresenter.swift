import DoomKitCore
import Foundation
import Observation

@MainActor
@Observable
public final class PointOfInterestPresenter: Identifiable {
    public let id = UUID()

    private var location: Location?
    private let fetchPharmacies: @Sendable (Location) async -> [PointOfInterest]?
    private let fetchHospitals: @Sendable (Location) async -> [PointOfInterest]?
    private let fetchLiquorStores: @Sendable (Location) async -> [PointOfInterest]?
    private let fetchFuneralDirectors: @Sendable (Location) async -> [PointOfInterest]?
    private let fetchCemeteries: @Sendable (Location) async -> [PointOfInterest]?

    public var pharmacies: [PointOfInterest]? = nil
    public var hospitals: [PointOfInterest]? = nil
    public var liquorStores: [PointOfInterest]? = nil
    public var funeralDirectors: [PointOfInterest]? = nil
    public var cemeteries: [PointOfInterest]? = nil

    public init(
        fetchPharmacies: @escaping @Sendable (Location) async -> [PointOfInterest]?,
        fetchHospitals: @escaping @Sendable (Location) async -> [PointOfInterest]?,
        fetchLiquorStores: @escaping @Sendable (Location) async -> [PointOfInterest]?,
        fetchFuneralDirectors: @escaping @Sendable (Location) async -> [PointOfInterest]?,
        fetchCemeteries: @escaping @Sendable (Location) async -> [PointOfInterest]?
    ) {
        self.fetchPharmacies = fetchPharmacies
        self.fetchHospitals = fetchHospitals
        self.fetchLiquorStores = fetchLiquorStores
        self.fetchFuneralDirectors = fetchFuneralDirectors
        self.fetchCemeteries = fetchCemeteries
    }

    public func updateLocation(_ location: Location) {
        self.location = location
        Task { @MainActor in
            await self.refresh()
        }
    }

    @MainActor
    public func refresh() async {
        if let location = self.location {
            let fetchPharmacies = self.fetchPharmacies
            let fetchHospitals = self.fetchHospitals
            let fetchLiquorStores = self.fetchLiquorStores
            let fetchFuneralDirectors = self.fetchFuneralDirectors
            let fetchCemeteries = self.fetchCemeteries

            async let pharmaciesData = fetchPharmacies(location)
            async let hospitalsData = fetchHospitals(location)
            async let liquorStoresData = fetchLiquorStores(location)
            async let funeralDirectorsData = fetchFuneralDirectors(location)
            async let cemeteriesData = fetchCemeteries(location)

            let (pharmacies, hospitals, liquorStores, funeralDirectors, cemeteries) = await (
                pharmaciesData,
                hospitalsData,
                liquorStoresData,
                funeralDirectorsData,
                cemeteriesData
            )

            self.pharmacies = pharmacies
            self.hospitals = hospitals
            self.liquorStores = liquorStores
            self.funeralDirectors = funeralDirectors
            self.cemeteries = cemeteries
        }
    }
}

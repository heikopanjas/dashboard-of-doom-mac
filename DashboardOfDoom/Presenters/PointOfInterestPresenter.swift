import Foundation
import SwiftUI

@Observable class PointOfInterestPresenter: Identifiable, LocationManagerDelegate {
    let id = UUID()

    private let pointOfInterestController = PointOfInterestController()
    private let locationManager = LocationManager()
    private var location: Location?

    var pharmacies: [PointOfInterest]? = nil
    var hospitals: [PointOfInterest]? = nil
    var liquorStores: [PointOfInterest]? = nil
    var funeralDirectors: [PointOfInterest]? = nil
    var cemeteries: [PointOfInterest]? = nil

    init() {
        self.locationManager.delegate = self
    }

    func locationManager(didUpdateLocation location: Location) {
        self.location = location
        Task {
            await self.refresh()
        }
    }

    @MainActor func refresh() async {
        if let location = self.location {
            // Launch all fetches in parallel
            async let pharmaciesData = self.pointOfInterestController.fetchPharmacies(location: location)
            async let hospitalsData = self.pointOfInterestController.fetchHospitals(location: location)
            async let liquorStoresData = self.pointOfInterestController.fetchLiquorStores(location: location)
            async let funeralDirectorsData = self.pointOfInterestController.fetchFuneralDirectors(location: location)
            async let cemeteriesData = self.pointOfInterestController.fetchCemeteries(location: location)

            // Await all results together
            let (pharmacies, hospitals, liquorStores, funeralDirectors, cemeteries) = await (pharmaciesData, hospitalsData, liquorStoresData, funeralDirectorsData, cemeteriesData)

            // Assign results to properties
            self.pharmacies = pharmacies
            self.hospitals = hospitals
            self.liquorStores = liquorStores
            self.funeralDirectors = funeralDirectors
            self.cemeteries = cemeteries
        }
    }
}

extension PointOfInterestPresenter {
    // Creates a binding for any property
    func binding<Value>(for keyPath: ReferenceWritableKeyPath<PointOfInterestPresenter, Value>) -> Binding<Value> {
        Binding(
            get: { self[keyPath: keyPath] },
            set: { self[keyPath: keyPath] = $0 }
        )
    }
}

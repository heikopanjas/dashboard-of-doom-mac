import DoomKitLocation
import Foundation
import SwiftUI

@MainActor @Observable class PointOfInterestPresenter: Identifiable {
    let id = UUID()

    private let pointOfInterestController = PointOfInterestController()
    private let locationManager = AppLocation.shared
    private var locationTask: Task<Void, Never>?
    private var refreshTask: Task<Void, Never>?
    private var location: Location?

    var pharmacies: [PointOfInterest]? = nil
    var hospitals: [PointOfInterest]? = nil
    var liquorStores: [PointOfInterest]? = nil
    var funeralDirectors: [PointOfInterest]? = nil
    var cemeteries: [PointOfInterest]? = nil

    init() {
        let updates = self.locationManager.updates()
        self.locationTask = Task { [weak self] in
            var previous: Location?
            for await state in updates {
                guard state.origin == .measured, state.location != previous else { continue }
                previous = state.location
                self?.locationManager(didUpdateLocation: state.location)
            }
        }
        self.locationManager.start()
    }

    isolated deinit {
        self.locationTask?.cancel()
        self.refreshTask?.cancel()
    }

    func locationManager(didUpdateLocation location: Location) {
        self.location = location
        self.refreshTask?.cancel()
        self.refreshTask = Task { [weak self] in
            await self?.refresh()
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

            guard Task.isCancelled == false else { return }
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

import Foundation
import SwiftUI

@Observable class HazardPresenter: Identifiable, LocationManagerDelegate {
    let id = UUID()

    private let hazardController = HazardController()
    private let locationManager = LocationManager()
    private var location: Location?

    var hazards: [Hazard]? = nil

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
            self.hazards = await self.hazardController.fetchHazards(location: location)
        }
    }
}

extension HazardPresenter {
    // Creates a binding for any property
    func binding<Value>(for keyPath: ReferenceWritableKeyPath<HazardPresenter, Value>) -> Binding<Value> {
        Binding(
            get: { self[keyPath: keyPath] },
            set: { self[keyPath: keyPath] = $0 }
        )
    }
}



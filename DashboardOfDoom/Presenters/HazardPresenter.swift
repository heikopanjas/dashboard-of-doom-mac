import DoomKitLocation
import Foundation
import SwiftUI

@MainActor @Observable class HazardPresenter: Identifiable {
    let id = UUID()

    private let hazardController = HazardController()
    private let locationManager = AppLocation.shared
    private var locationTask: Task<Void, Never>?
    private var refreshTask: Task<Void, Never>?
    private var location: Location?

    var hazards: [Hazard]? = nil

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
            let hazards = await self.hazardController.fetchHazards(location: location)
            guard Task.isCancelled == false else { return }
            self.hazards = hazards
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



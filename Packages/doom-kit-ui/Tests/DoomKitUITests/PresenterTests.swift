import DoomKitCore
import DoomKitUI
import Foundation
import Testing

@Test
@MainActor
func hazardPresenterFetchesHazardsOnLocationUpdate() async {
    let hazard = Hazard(
        id: "test-hazard",
        headline: "Test",
        description: "Description",
        severity: "Minor",
        timestamp: Date()
    )
    let presenter = HazardPresenter { _ in
        [hazard]
    }

    presenter.updateLocation(Location(latitude: 52.0, longitude: 13.0))
    try? await Task.sleep(for: .milliseconds(100))

    #expect(presenter.hazards.count == 1)
    #expect(presenter.hazards.first?.headline == "Test")
}

@Test
@MainActor
func hazardPresenterRefreshWithoutLocationDoesNothing() async {
    let presenter = HazardPresenter { _ in
        [
            Hazard(
                id: "unused",
                headline: "Should not load",
                description: "",
                severity: "Minor",
                timestamp: Date()
            )
        ]
    }

    await presenter.refresh()

    #expect(presenter.hazards.isEmpty == true)
}

@Test
@MainActor
func pointOfInterestPresenterFetchesAllCategories() async {
    let point = PointOfInterest(
        name: "Test POI",
        location: Location(latitude: 52.0, longitude: 13.0)
    )
    let presenter = PointOfInterestPresenter(
        fetchPharmacies: { _ in [point] },
        fetchHospitals: { _ in [point] },
        fetchLiquorStores: { _ in [point] },
        fetchFuneralDirectors: { _ in [point] },
        fetchCemeteries: { _ in [point] }
    )

    presenter.updateLocation(Location(latitude: 52.0, longitude: 13.0))
    try? await Task.sleep(for: .milliseconds(150))

    #expect(presenter.pharmacies.count == 1)
    #expect(presenter.hospitals.count == 1)
    #expect(presenter.liquorStores.count == 1)
    #expect(presenter.funeralDirectors.count == 1)
    #expect(presenter.cemeteries.count == 1)
}

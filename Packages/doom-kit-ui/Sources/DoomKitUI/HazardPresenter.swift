import DoomKitCore
import Foundation
import Observation

@MainActor
@Observable
public final class HazardPresenter: Identifiable {
    public let id = UUID()

    private var location: Location?
    private let fetchHazards: @Sendable (Location) async -> [Hazard]

    public var hazards: [Hazard] = []

    public init(fetchHazards: @escaping @Sendable (Location) async -> [Hazard]) {
        self.fetchHazards = fetchHazards
    }

    public func updateLocation(_ location: Location) {
        self.location = location
        Task { await self.refresh() }
    }

    public func refresh() async {
        if let location = self.location {
            self.hazards = await self.fetchHazards(location)
        }
    }
}

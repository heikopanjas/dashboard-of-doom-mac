import DoomKit
import Foundation

@MainActor
final class AppProcessControl {
    static let shared = AppProcessControl()

    let processManager: ProcessManager
    let locationManager: LocationManager

    private var hazardPresenter: HazardPresenter?
    private var pointOfInterestPresenter: PointOfInterestPresenter?
    private var processPresenterRegistrations: [ProcessPresenterRegistration] = []

    private init() {
        self.processManager = ProcessManager(dependencies: ProcessRuntimeAdapter.makeDependencies())
        self.locationManager = LocationManager()
    }

    func configure(hazardPresenter: HazardPresenter, pointOfInterestPresenter: PointOfInterestPresenter) {
        self.hazardPresenter = hazardPresenter
        self.pointOfInterestPresenter = pointOfInterestPresenter
    }

    func start() -> Void {
        self.locationManager.onLocationUpdate = { location in
            self.hazardPresenter?.updateLocation(location)
            self.pointOfInterestPresenter?.updateLocation(location)
            Task {
                await self.processManager.updateLocation(location)
            }
        }
        Task {
            await self.processManager.start()
        }
    }

    func register(presenter: any ProcessRefreshProtocol, timeout: TimeInterval) async -> Void {
        let presenterId = presenter.id
        let subscription = ProcessSubscription(
            id: presenterId,
            timeout: timeout * 60,
            refresh: { location in
                await presenter.refreshData(location: location)
            }
        )
        await self.processManager.add(subscription: subscription)
    }

    func refreshSubscription(presenterId: UUID) async -> Void {
        await self.processManager.refreshSubscription(subscriberId: presenterId)
    }

    func registerProcessPresenters(_ registrations: [ProcessPresenterRegistration]) async -> Void {
        self.processPresenterRegistrations = registrations
        for registration in registrations {
            await self.register(registration: registration)
        }
    }

    func reregisterProcessPresenters(forIntervalKey intervalKey: String) async -> Void {
        for registration in self.processPresenterRegistrations where registration.refreshIntervalKey == intervalKey {
            await self.register(registration: registration)
        }
    }

    private func register(registration: ProcessPresenterRegistration) async -> Void {
        let storedInterval = UserDefaults.standard.integer(forKey: registration.refreshIntervalKey)
        let minutes = TimeInterval(storedInterval > 0 ? storedInterval : Int(registration.defaultMinutes))
        await self.register(presenter: registration.presenter, timeout: minutes)
    }
}

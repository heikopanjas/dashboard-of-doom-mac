import CoreLocation

@MainActor
final class CoreLocationProvider: LocationProvider {
    private var manager: CLLocationManager?
    private var delegate: Delegate?
    var onUpdate: (@MainActor (LocationProviderUpdate) -> Void)?

    func start() {
        guard self.manager == nil else { return }
        let manager = CLLocationManager()
        let delegate = Delegate()
        // Capture this lifecycle's handler, so queued callbacks cannot adopt a new one.
        delegate.receive = self.onUpdate
        manager.delegate = delegate
        self.manager = manager
        self.delegate = delegate
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    func stop() {
        self.manager?.stopUpdatingLocation()
        self.manager?.delegate = nil
        self.delegate?.receive = nil
        self.manager = nil
        self.delegate = nil
    }

    @MainActor private final class Delegate: NSObject, @preconcurrency CLLocationManagerDelegate {
        var receive: (@MainActor (LocationProviderUpdate) -> Void)?

        private func authorization(_ manager: CLLocationManager) -> LocationState.Authorization {
            switch manager.authorizationStatus {
                case .authorizedAlways, .authorizedWhenInUse: return .authorized
                case .denied: return .denied
                case .restricted: return .restricted
                default: return .notDetermined
            }
        }

        func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            self.receive?(.init(authorization: self.authorization(manager)))
        }

        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let location = locations.last else { return }
            self.receive?(
                .init(
                    location: Location(
                        latitude: location.coordinate.latitude,
                        longitude: location.coordinate.longitude),
                    authorization: self.authorization(manager)))
        }

        func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
            let code = (error as NSError).code
            let failure: LocationState.Failure =
                code == CLError.denied.rawValue ? .denied : (code == CLError.locationUnknown.rawValue ? .unavailable : .other(code))
            self.receive?(.init(authorization: self.authorization(manager), failure: failure))
        }
    }
}

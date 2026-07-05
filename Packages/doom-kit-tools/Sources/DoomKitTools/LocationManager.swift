import CoreLocation
import DoomKitCore
import Foundation

public class LocationManager: NSObject, CLLocationManagerDelegate {
    public static let houseOfWorldCultures = Location(latitude: 52.51889, longitude: 13.36528)
    private var locationManager = CLLocationManager()
    public var location: Location?
    public var onLocationUpdate: ((Location) -> Void)?

    public override init() {
        super.init()
        self.location = Self.houseOfWorldCultures
        self.locationManager.delegate = self
        #if os(iOS)
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest

        self.locationManager.allowsBackgroundLocationUpdates = true
        self.locationManager.pausesLocationUpdatesAutomatically = false
        self.locationManager.showsBackgroundLocationIndicator = true
        #else
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        #endif
        self.locationManager.startUpdatingLocation()
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLocation = locations.last {
            let latitude = lastLocation.coordinate.latitude
            let longitude = lastLocation.coordinate.longitude
            self.updateLocation(location: Location(latitude: latitude, longitude: longitude))
        }
    }

    public func updateLocation(location: Location) -> Void {
        var needsUpdate = false
        if self.location == nil {
            needsUpdate = true
            trace.debug("Location update: no previous location")
        }
        else if self.significantLocationChange(previous: self.location, current: location) {
            needsUpdate = true
            if let prev = self.location {
                let distance = haversineDistance(location_0: prev, location_1: location)
                trace.debug("Location update: significant change, distance=\(distance.converted(to: .meters).value)m")
            }
        }
        else {
            if let prev = self.location {
                let distance = haversineDistance(location_0: prev, location_1: location)
                trace.debug("Location update: ignored (within deadband), distance=\(distance.converted(to: .meters).value)m")
            }
        }

        if needsUpdate == true {
            self.location = location
            if let onLocationUpdate = self.onLocationUpdate {
                onLocationUpdate(location)
            }
        }
    }

    private func significantLocationChange(previous: Location?, current: Location) -> Bool {
        guard let previous = previous else { return true }
        let deadband = Measurement(value: 100.0, unit: UnitLength.meters)
        let distance = haversineDistance(location_0: previous, location_1: current)
        return distance > deadband
    }

    public static func reverseGeocodeLocation(latitude: Double, longitude: Double, fullAddress: Bool = true) async -> String? {
        var formattedPlacemark: String?
        do {
            let geocoder = CLGeocoder()
            let coordinate = CLLocation(latitude: latitude, longitude: longitude)
            let placemarks = try await geocoder.reverseGeocodeLocation(coordinate)
            if let placemark = placemarks.first {
                formattedPlacemark = (fullAddress == true) ? formatPlacemarkLong(placemark: placemark) : formatPlacemarkShort(placemark: placemark)
            }
        }
        catch {
            print("Failed to reverse geocode location: \(error)")
            formattedPlacemark = nil
        }
        return formattedPlacemark
    }

    public static func fetchConstituency(location: Location) async throws -> String? {
        var constituency: String? = nil
        do {
            let geocoder = CLGeocoder()
            let coordinate = CLLocation(latitude: location.latitude, longitude: location.longitude)
            let placemarks = try await geocoder.reverseGeocodeLocation(coordinate)
            if let placemark = placemarks.first {
                if placemark.administrativeArea != nil {
                    constituency = placemark.administrativeArea
                }
                else if placemark.subAdministrativeArea != nil {
                    constituency = placemark.subAdministrativeArea
                }
                else if placemark.locality != nil {
                    constituency = placemark.locality
                }
            }
        }
        catch {
            print("Failed to reverse geocode location: \(error)")
        }
        return constituency
    }

    public static func reverseGeocodeLocation(location: Location, fullAddress: Bool = true) async -> String? {
        return await self.reverseGeocodeLocation(latitude: location.latitude, longitude: location.longitude, fullAddress: fullAddress)
    }

    static private func formatPlacemarkLong(placemark: CLPlacemark) -> String? {
        var formattedPlacemark = ""

        if let name = placemark.name {
            formattedPlacemark += name
        }
        if let postalCode = placemark.postalCode, let locality = placemark.locality {
            if formattedPlacemark.isEmpty == false {
                formattedPlacemark += ", "
            }
            formattedPlacemark += postalCode + " " + locality
            if let subLocality = placemark.subLocality {
                if formattedPlacemark.isEmpty == false {
                    formattedPlacemark += "-"
                }
                formattedPlacemark += subLocality
            }
        }
        return formattedPlacemark
    }

    static private func formatPlacemarkShort(placemark: CLPlacemark) -> String? {
        var formattedPlacemark = ""
        if let locality = placemark.locality {
            formattedPlacemark += locality
        }
        if let subLocality = placemark.subLocality {
            formattedPlacemark += "-" + subLocality
        }
        return formattedPlacemark
    }
}

#if os(macOS) && DEBUG
import DoomKitLocation
import DoomKitProcess
import MapKit
import SwiftUI

/// No live services, location tracking, timers, or preference writes in these fixtures.
private struct MapAnnotationPreview: View {
    private let annotations: [MapAnnotationSnapshot]
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 52.52, longitude: 13.405), span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.12))
    )

    var body: some View {
        CollisionMapView(position: self.$position, annotations: self.annotations)
    }

    init(coincident: Bool, separated: Bool = false) {
        let selectors: [ProcessSelector] = [
            .weather(.temperature), .covid(.incidence), .particle(.pm10), .water(.level), .radiation(.total), .survey(.fascists)
        ]
        let icons = ["thermometer", "cross.case", "aqi.medium", "water.waves", "atom", "chart.bar"]
        let values = ["22.0 °C", "Ω 12.3", "18 µg/m³", "2.73 m", "0.08 µSv/h", "ν 20.0 %"]
        self.annotations = selectors.enumerated().map { index, selector in
            let presenter = ProcessPresenter()
            let location =
                separated == true
                ? Location(latitude: 52.505 + Double(index / 3) * 0.03, longitude: 13.365 + Double(index % 3) * 0.04)
                : Location(latitude: 52.52 + (coincident == true ? 0 : Double(index) * 0.001), longitude: 13.405)
            presenter.sensor = ProcessSensor(
                name: "Fixture", location: location,
                placemark: "Berlin", customData: ["icon": icons[index]], measurements: [:], timestamp: nil)
            presenter.faceplate[selector] = values[index]
            return MapAnnotationSnapshot(id: String(index), presenter: presenter, selector: selector, user: index == 0)
        }
    }
}

#Preview("Separated locations without connectors") {
    MapAnnotationPreview(coincident: false, separated: true).frame(width: 600, height: 400)
}

#Preview("Six coincident locations") {
    MapAnnotationPreview(coincident: true).frame(width: 600, height: 400)
}

#Preview("Dense cluster, narrow map") {
    MapAnnotationPreview(coincident: false).frame(width: 360, height: 300)
}

#Preview("Undersized viewport") {
    MapAnnotationPreview(coincident: true).frame(width: 200, height: 120)
}
#endif

import DoomKitProcess
import MapKit
import SwiftUI

#if os(macOS)
private struct MapAppearanceView: NSViewRepresentable {
    let colorScheme: ColorScheme

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        applyAppearance(from: view)
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        applyAppearance(from: nsView)
    }

    private func applyAppearance(from view: NSView) {
        DispatchQueue.main.async {
            var ancestor = view.superview
            while let currentView = ancestor {
                if let mapView = findMapView(in: currentView) {
                    mapView.appearance = NSAppearance(
                        named: colorScheme == .dark ? .darkAqua : .aqua
                    )
                    mapView.needsDisplay = true
                    return
                }
                ancestor = currentView.superview
            }
        }
    }

    private func findMapView(in view: NSView) -> MKMapView? {
        if let mapView = view as? MKMapView {
            return mapView
        }
        for subview in view.subviews {
            if let mapView = findMapView(in: subview) {
                return mapView
            }
        }
        return nil
    }
}
#endif

struct MapView: View {
    @Environment(PointOfInterestPresenter.self) private var pointOfInterestPresenter
    @Environment(\.colorScheme) private var colorScheme
    @Environment(WeatherPresenter.self) private var weather
    @Environment(CovidPresenter.self) private var incidence
    @Environment(LevelPresenter.self) private var water
    @Environment(RadiationPresenter.self) private var radiation
    @Environment(ParticlePresenter.self) private var particle
    @Environment(SurveyPresenter.self) private var surveys

    // Settings - using @AppStorage to observe changes and trigger re-render
    @AppStorage("showWeather") private var showWeather: Bool = true
    @AppStorage("showCovid") private var showCovid: Bool = true
    @AppStorage("showLevels") private var showLevels: Bool = true
    @AppStorage("showRadiation") private var showRadiation: Bool = true
    @AppStorage("showParticles") private var showParticles: Bool = true
    @AppStorage("showElectionPolls") private var showElectionPolls: Bool = true

    private var viewModel = MapPresenter.shared

    //    private var cameraPosition: Binding<MapCameraPosition> {
    //        Binding(
    //            get: { self.viewModel.region },
    //            set: { self.viewModel.region = $0 }
    //        )
    //    }

    var body: some View {
        VStack {
            if let sensor = weather.sensor {
                #if os(macOS)
                HStack(alignment: .bottom) {
                    Image(systemName: "safari")
                    Text(String(format: "%@", sensor.placemark ?? "<Unknown>"))
                    Spacer()
                    Text("Last update: \(Date.absoluteString(date: sensor.timestamp))")
                        .foregroundColor(.gray)
                }
                //                .padding(.vertical, 5)
                .padding(.leading, 5)
                .font(.footnote)
                #else
                VStack(alignment: .leading) {
                    HStack(alignment: .bottom) {
                        Image(systemName: "safari")
                        Text(String(format: "%@", sensor.placemark ?? "<Unknown>"))
                        Spacer()
                    }
                    HStack {
                        Text("Last update: \(Date.absoluteString(date: sensor.timestamp))")
                            .foregroundColor(.gray)
                        Spacer()
                    }
                }
                .font(.footnote)
                #endif
            }

            if weather.timestamp == nil {
                ActivityIndicator()
            }
            else {
                VStack {
                    #if os(macOS)
                    CollisionMapView(position: self.viewModel.binding(for: \.region), annotations: self.annotations, pointsOfInterest: self.pointOfInterestPresenter.points)
                        .background(MapAppearanceView(colorScheme: self.colorScheme))
                    #else
                    Map(position: viewModel.binding(for: \.region), interactionModes: []) {
                        MapAnnotation(
                            presenter: weather, selector: .weather(.temperature), user: true,
                            simple: !showWeather)

                        if showCovid {
                            MapAnnotation(presenter: incidence, selector: .covid(.incidence))
                        }

                        if showParticles {
                            if let selector = particle.measurements.first?.key {
                                MapAnnotation(presenter: particle, selector: selector)
                            }
                        }

                        if showLevels {
                            MapAnnotation(presenter: water, selector: .water(.level))
                        }

                        if showRadiation {
                            MapAnnotation(presenter: radiation, selector: .radiation(.total))
                        }

                        if showElectionPolls {
                            MapAnnotation(presenter: surveys, selector: .survey(.fascists))
                        }
                    }
                    .allowsHitTesting(false)
                    #endif
                }
            }
        }
        .onChange(of: showCovid) { _, newValue in
            updateMapRegion(for: incidence, visible: newValue)
        }
        .onChange(of: showLevels) { _, newValue in
            updateMapRegion(for: water, visible: newValue)
        }
        .onChange(of: showRadiation) { _, newValue in
            updateMapRegion(for: radiation, visible: newValue)
        }
        .onChange(of: showParticles) { _, newValue in
            updateMapRegion(for: particle, visible: newValue)
        }
        .onChange(of: showElectionPolls) { _, newValue in
            updateMapRegion(for: surveys, visible: newValue)
        }
    }

    // Category identities survive presenter refreshes and replacement measurement UUIDs.
    private var annotations: [MapAnnotationSnapshot] {
        var result = [MapAnnotationSnapshot(id: "weather", presenter: self.weather, selector: .weather(.temperature), user: true, showsLabel: self.showWeather)]
        if self.showCovid == true {
            result.append(MapAnnotationSnapshot(id: "covid", presenter: self.incidence, selector: .covid(.incidence)))
        }
        if self.showParticles == true, let selector = self.particle.measurements.first?.key {
            result.append(MapAnnotationSnapshot(id: "particles", presenter: self.particle, selector: selector))
        }
        if self.showLevels == true {
            result.append(MapAnnotationSnapshot(id: "water", presenter: self.water, selector: .water(.level)))
        }
        if self.showRadiation == true {
            result.append(MapAnnotationSnapshot(id: "radiation", presenter: self.radiation, selector: .radiation(.total)))
        }
        if self.showElectionPolls == true {
            result.append(MapAnnotationSnapshot(id: "surveys", presenter: self.surveys, selector: .survey(.fascists)))
        }
        return result
    }

    private func updateMapRegion(for presenter: ProcessPresenter, visible: Bool) {
        if visible, let sensor = presenter.sensor {
            MapPresenter.shared.updateRegion(for: presenter.id, with: sensor.location)
        }
        else {
            MapPresenter.shared.updateRegion(remove: presenter.id)
        }
    }
}

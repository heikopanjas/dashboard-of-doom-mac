import MapKit
import SwiftUI

struct MapView: View {
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

    private func updateMapRegion(for presenter: ProcessPresenter, visible: Bool) {
        if visible, let sensor = presenter.sensor {
            MapPresenter.shared.updateRegion(for: presenter.id, with: sensor.location)
        } else {
            MapPresenter.shared.updateRegion(remove: presenter.id)
        }
    }
}

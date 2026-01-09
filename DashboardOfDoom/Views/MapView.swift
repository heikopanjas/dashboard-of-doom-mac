import MapKit
import SwiftUI

struct MapView: View {
    @Environment(WeatherPresenter.self) private var weather
    @Environment(CovidPresenter.self) private var incidence
    @Environment(LevelPresenter.self) private var water
    @Environment(RadiationPresenter.self) private var radiation
    @Environment(ParticlePresenter.self) private var particle
    @Environment(SurveyPresenter.self) private var surveys

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
                            simple: UserDefaults.standard.bool(forKey: "showWeather") == false)

                        if UserDefaults.standard.bool(forKey: "showCovid") == true {
                            MapAnnotation(presenter: incidence, selector: .covid(.incidence))
                        }

                        if UserDefaults.standard.bool(forKey: "showParticles") == true {
                            if let selector = particle.measurements.first?.key {
                                MapAnnotation(presenter: particle, selector: selector)
                            }
                        }

                        if UserDefaults.standard.bool(forKey: "showLevels") == true {
                            MapAnnotation(presenter: water, selector: .water(.level))
                        }

                        if UserDefaults.standard.bool(forKey: "showRadiation") == true {
                            MapAnnotation(presenter: radiation, selector: .radiation(.total))
                        }

                        if UserDefaults.standard.bool(forKey: "showElectionPolls") == true {
                            MapAnnotation(presenter: surveys, selector: .survey(.fascists))
                        }
                    }
                    .allowsHitTesting(false)
                }
            }
        }
    }
}

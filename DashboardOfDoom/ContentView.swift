import DoomKit
import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(WeatherPresenter.self) private var viewModel
    @Environment(AppDelegate.self) private var appDelegate

    var body: some View {
        VStack {
            HStack {
                if colorScheme == .light {
                    Text("Dashboard of Doom")
                        .font(.headline)
                        .padding(.top, 10)
                }
                else {
                    Image("dashboard-of-doom-logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 34)
                        .padding(.top, 10)
                }
                Spacer()
                HStack(spacing: 12) {
                    Button {
                        appDelegate.showSettings()
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .imageScale(.large)
                    }
                    .buttonStyle(GrowingButtonStyle())
                    .focusable(false)

                    Button {
                        NSApplication.shared.terminate(nil)
                    } label: {
                        Image(systemName: "togglepower")
                            .imageScale(.large)
                    }
                    .buttonStyle(GrowingButtonStyle())
                    .focusable(false)
                }
            }
            .padding()
            .frame(height: 34)
            .background(Color(light: .white, dark: Color(hex: "#000000")))
            ScrollView {
                VStack {
                    MapView()
                        .padding(.horizontal)
                        .cornerRadius(13)
                        .padding(.vertical, 5)
                        .modifier(MapSizeModifier())
                    Divider()
                    ContentPanelView(label: "Weather Forecast", icon: "cloud.sun") {
                        ForecastView()
                            .padding(5)
                            .padding(.trailing, 10)
                    }
                    Divider()
                    ContentPanelView(label: "COVID-19", icon: "facemask") {
                        CovidView()
                            .padding(5)
                            .padding(.trailing, 10)
                    }
                    Divider()
                    ContentPanelView(label: "Level", icon: "water.waves") {
                        LevelView()
                            .padding(5)
                            .padding(.trailing, 10)
                    }
                    Divider()
                    ContentPanelView(label: "Radiation", icon: "atom") {
                        RadiationView()
                            .padding(5)
                            .padding(.trailing, 10)
                    }
                    Divider()
                    ContentPanelView(label: "Particulate Matter", icon: "aqi.medium") {
                        ParticleView()
                            .padding(5)
                            .padding(.trailing, 10)
                    }
                    Divider()
                    ContentPanelView(label: "Election Polls", icon: "popcorn") {
                        SurveyView()
                            .padding(5)
                            .padding(.trailing, 10)
                    }
                }
                .background(Color(light: .white, dark: Color(hex: "#000000")))
            }
            .scrollContentBackground(.hidden)
            .background(Color(light: .white, dark: Color(hex: "#000000")))
            .padding(.bottom, 10)
        }
        .frame(width: 800, height: 859)
        .foregroundStyle(Color(light: .primary, dark: .cyan))
        .background(Color(light: .white, dark: Color(hex: "#000000")))
    }
}

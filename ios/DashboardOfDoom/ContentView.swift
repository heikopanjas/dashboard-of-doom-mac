import Charts
import MapKit
import SwiftUI

struct MapSizeModifier: ViewModifier {
    @ScaledMetric(relativeTo: .footnote) private var headerHeight = 36.0
    func body(content: Content) -> some View {
        #if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .pad {
            content
                .frame(height: 667 + max(self.headerHeight - 36, 0))
        }
        else {
            content
                .frame(height: 367 + max(self.headerHeight - 36, 0))
        }
        #else
        content
            .frame(height: 500)
        #endif
    }
}

struct ContentView: View {
    @AppStorage("enableElectionPolls") private var enableElectionPolls: Bool = false
    @State private var selectedScreen = Screen.home
    @State private var navigationVisible = Visibility.hidden
    @State private var navigationTitle = ""

    enum Screen {
        case home
        case weather
        case covid
        case environment
        case particles
        case surveys
        case settings
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 10) {
                    HStack {
                        Image("dashboard-of-doom-logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 200, height: 34)
                            .padding(.top, 10)
                            .padding(.leading, 5)
                        Spacer()
                    }
                    switch selectedScreen {
                        case .home:
                            VStack {
                                MapView()
                                    .padding(5)
                                    .padding(.trailing, 5)
                                    .modifier(MapSizeModifier())
                                Divider()
                                LevelView()
                                    .padding(5)
                                    .padding(.trailing, 3)
                                Divider()
                                    .padding(.horizontal, 5)
                                    .padding(.trailing, 5)
                                RadiationView()
                                    .padding(5)
                                    .padding(.trailing, 3)
//                                Divider()
//                                HazardView()
//                                    .padding(5)
//                                    .padding(.trailing, 3)
                            }
                            .onAppear {
                                navigationVisible = .visible
                                navigationTitle = "Home"
                            }
                        case .weather:
                            VStack {
                                ForecastView()
                                    .padding(5)
                                    .padding(.trailing, 3)
                            }
                            .onAppear {
                                navigationVisible = .visible
                                navigationTitle = "Weather Forecast"
                            }
                        case .covid:
                            VStack {
                                CovidView()
                                    .padding(5)
                                    .padding(.trailing, 3)
                            }
                            .onAppear {
                                navigationVisible = .visible
                                navigationTitle = "COVID-19 Situation"
                            }
                        case .environment:
                            VStack {
                                RadiationView()
                                    .padding(5)
                                    .padding(.trailing, 3)
                                Divider()
                                    .padding(.horizontal, 5)
                                    .padding(.trailing, 5)
                                LevelView()
                                    .padding(5)
                                    .padding(.trailing, 3)
                            }
                            .onAppear {
                                navigationVisible = .visible
                                navigationTitle = "Environmental Conditions"
                            }
                        case .particles:
                            VStack {
                                ParticleView()
                                    .padding(5)
                                    .padding(.trailing, 3)
                            }
                            .onAppear {
                                navigationVisible = .visible
                                navigationTitle = "Particulate Matter"
                            }
                        case .surveys:
                            if enableElectionPolls == true {
                                VStack {
                                    SurveyView()
                                        .padding(5)
                                        .padding(.trailing, 3)
                                }
                                .onAppear {
                                    navigationVisible = .visible
                                    navigationTitle = "Election Polls"
                                }
                            }
                        case .settings:
                            VStack {
                                SettingsView()
                                    .padding(5)
                                    .padding(.trailing, 3)
                            }
                            .onAppear {
                                navigationVisible = .visible
                                navigationTitle = "Settings"
                            }
                    }
                }
                .frame(maxWidth: .infinity)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        HStack {
                            Text(navigationTitle)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.headline)
                            Spacer()
                        }
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .bottomBar) {
                        HStack {
                            Button(action: { selectedScreen = .home }) {
                                Image(systemName: selectedScreen == .home ? "house.fill" : "house")
                                    .foregroundColor(selectedScreen == .home ? .accentColor : .accentColor.opacity(0.5))
                            }
                            .accessibilityLabel("Home")
                            Spacer()
                            Button(action: { selectedScreen = .weather }) {
                                Image(systemName: selectedScreen == .weather ? "cloud.bolt.fill" : "cloud.bolt")
                                    .foregroundColor(selectedScreen == .weather ? .accentColor : .accentColor.opacity(0.5))
                            }
                            .accessibilityLabel("Weather")
                            Spacer()
                            Button(action: { selectedScreen = .covid }) {
                                Image(systemName: selectedScreen == .covid ? "facemask.fill" : "facemask")
                                    .foregroundColor(selectedScreen == .covid ? .accentColor : .accentColor.opacity(0.5))
                            }
                            .accessibilityLabel("COVID-19")
                            Spacer()
                            Button(action: { selectedScreen = .environment }) {
                                Image(systemName: selectedScreen == .environment ? "leaf.fill" : "leaf")
                                    .foregroundColor(selectedScreen == .environment ? .accentColor : .accentColor.opacity(0.5))
                            }
                            .accessibilityLabel("Environment")
                            Spacer()
                            Button(action: { selectedScreen = .particles }) {
                                Image(systemName: selectedScreen == .particles ? "aqi.medium" : "aqi.low")
                                    .foregroundColor(selectedScreen == .particles ? .accentColor : .accentColor.opacity(0.5))
                                    .fontWeight(.black)  // Workaround for "aqi.medium" icon being rather thin
                            }
                            .accessibilityLabel("Particles")
                            if enableElectionPolls == true {
                                Spacer()
                                Button(action: { selectedScreen = .surveys }) {
                                    Image(systemName: selectedScreen == .surveys ? "popcorn.fill" : "popcorn")
                                        .foregroundColor(selectedScreen == .surveys ? .accentColor : .accentColor.opacity(0.5))
                                }
                            .accessibilityLabel("Election Polls")
                            }
                            Spacer()
                            Button(action: { selectedScreen = .settings }) {
                                Image(systemName: selectedScreen == .settings ? "gearshape.fill" : "gearshape")
                                    .foregroundColor(selectedScreen == .settings ? .accentColor : .accentColor.opacity(0.5))
                            }
                            .accessibilityLabel("Settings")
                        }
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .toolbarBackground(.visible, for: .bottomBar)
            .toolbarBackground(
                Color(
                    uiColor: UIColor { traitCollection in
                        traitCollection.userInterfaceStyle == .dark ? .black : .white
                    }), for: .bottomBar
            )
            .onChange(of: self.enableElectionPolls) { _, enabled in
                if enabled == false && self.selectedScreen == .surveys {
                    self.selectedScreen = .home
                }
            }
            .refreshable {
                if self.selectedScreen != .settings {
                    AppProcess.shared.refreshSubscriptions()
                }
            }
        }
    }
}

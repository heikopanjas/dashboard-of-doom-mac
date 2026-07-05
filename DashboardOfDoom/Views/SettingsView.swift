import DoomKit
import LaunchAtLogin
import SwiftUI

struct SettingsView: View {
    @State private var selectedTab: SettingsTab = .general

    // Presenters for triggering refreshes when settings change
    var levelPresenter: LevelPresenter?
    var particlePresenter: ParticlePresenter?
    var surveyPresenter: SurveyPresenter?

    // Enable toggles
    @AppStorage("showWeather") private var showWeather: Bool = true
    @AppStorage("showCovid") private var showCovid: Bool = true
    @AppStorage("showLevels") private var showLevels: Bool = true
    @AppStorage("showRadiation") private var showRadiation: Bool = true
    @AppStorage("showParticles") private var showParticles: Bool = true
    @AppStorage("showElectionPolls") private var showElectionPolls: Bool = true

    // Sensor preferences
    @AppStorage("nearestLevelSensor") private var nearestLevelSensor: Bool = false
    @AppStorage("nearestParticleSensor") private var nearestParticleSensor: Bool = false

    // Election poll scope
    @AppStorage("electionPollScope") private var electionPollScope: Int = 1

    // Appearance
    @AppStorage("alwaysUseDarkTheme") private var alwaysUseDarkTheme: Bool = true

    // Refresh intervals (in minutes)
    @AppStorage("weatherRefreshInterval") private var weatherRefreshInterval: Int = 5
    @AppStorage("covidRefreshInterval") private var covidRefreshInterval: Int = 360
    @AppStorage("levelRefreshInterval") private var levelRefreshInterval: Int = 15
    @AppStorage("radiationRefreshInterval") private var radiationRefreshInterval: Int = 15
    @AppStorage("particleRefreshInterval") private var particleRefreshInterval: Int = 30
    @AppStorage("surveyRefreshInterval") private var surveyRefreshInterval: Int = 360

    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            HStack(spacing: 2) {
                ForEach(SettingsTab.allCases, id: \.self) { tab in
                    SettingsToolbarButton(
                        tab: tab,
                        isSelected: selectedTab == tab,
                        action: { selectedTab = tab }
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 6)

            Divider()

            // Content
            Group {
                switch selectedTab {
                    case .general:
                        generalContent
                    case .weather:
                        weatherContent
                    case .covid:
                        covidContent
                    case .level:
                        levelContent
                    case .radiation:
                        radiationContent
                    case .particles:
                        particlesContent
                    case .polls:
                        pollsContent
                    case .about:
                        aboutContent
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: 660, height: 400)
        .background(Color(light: .white, dark: Color(hex: "#000000")))
        .onChange(of: nearestLevelSensor) { _, _ in
            if let presenter = levelPresenter {
                Task {
                    await AppProcessControl.shared.refreshSubscription(presenterId: presenter.id)
                }
            }
        }
        .onChange(of: nearestParticleSensor) { _, _ in
            if let presenter = particlePresenter {
                Task {
                    await AppProcessControl.shared.refreshSubscription(presenterId: presenter.id)
                }
            }
        }
        .onChange(of: electionPollScope) { _, _ in
            if let presenter = surveyPresenter {
                Task {
                    await AppProcessControl.shared.refreshSubscription(presenterId: presenter.id)
                }
            }
        }
        .onChange(of: weatherRefreshInterval) { _, _ in
            Task {
                await AppProcessControl.shared.reregisterProcessPresenters(forIntervalKey: "weatherRefreshInterval")
            }
        }
        .onChange(of: covidRefreshInterval) { _, _ in
            Task {
                await AppProcessControl.shared.reregisterProcessPresenters(forIntervalKey: "covidRefreshInterval")
            }
        }
        .onChange(of: levelRefreshInterval) { _, _ in
            Task {
                await AppProcessControl.shared.reregisterProcessPresenters(forIntervalKey: "levelRefreshInterval")
            }
        }
        .onChange(of: radiationRefreshInterval) { _, _ in
            Task {
                await AppProcessControl.shared.reregisterProcessPresenters(forIntervalKey: "radiationRefreshInterval")
            }
        }
        .onChange(of: particleRefreshInterval) { _, _ in
            Task {
                await AppProcessControl.shared.reregisterProcessPresenters(forIntervalKey: "particleRefreshInterval")
            }
        }
        .onChange(of: surveyRefreshInterval) { _, _ in
            Task {
                await AppProcessControl.shared.reregisterProcessPresenters(forIntervalKey: "surveyRefreshInterval")
            }
        }
    }

    // MARK: - Tab Content Views

    private var generalContent: some View {
        Form {
            Section("Application") {
                LaunchAtLogin.Toggle("Launch at Login")
            }
            Section("Appearance") {
                Toggle("Always Use Dark Theme", isOn: $alwaysUseDarkTheme)
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }

    private var weatherContent: some View {
        Form {
            Section("Data Source") {
                Toggle("Enable Weather Data", isOn: $showWeather)
            }
            Section("Refresh") {
                RefreshRatePicker(label: "Update Interval", interval: $weatherRefreshInterval)
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }

    private var covidContent: some View {
        Form {
            Section("Data Source") {
                Toggle("Enable COVID-19 Data", isOn: $showCovid)
            }
            Section("Refresh") {
                RefreshRatePicker(label: "Update Interval", interval: $covidRefreshInterval)
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }

    private var levelContent: some View {
        Form {
            Section("Data Source") {
                Toggle("Enable Water Level Data", isOn: $showLevels)
            }
            Section("Sensor") {
                Toggle("Use Nearest Sensor", isOn: $nearestLevelSensor)
                    .help("When enabled, shows data from the closest water level sensor to your location")
            }
            Section("Refresh") {
                RefreshRatePicker(label: "Update Interval", interval: $levelRefreshInterval)
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }

    private var radiationContent: some View {
        Form {
            Section("Data Source") {
                Toggle("Enable Radiation Data", isOn: $showRadiation)
            }
            Section("Refresh") {
                RefreshRatePicker(label: "Update Interval", interval: $radiationRefreshInterval)
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }

    private var particlesContent: some View {
        Form {
            Section("Data Source") {
                Toggle("Enable Particulate Matter Data", isOn: $showParticles)
            }
            Section("Sensor") {
                Toggle("Use Nearest Sensor", isOn: $nearestParticleSensor)
                    .help("When enabled, shows data from the closest air quality sensor to your location")
            }
            Section("Refresh") {
                RefreshRatePicker(label: "Update Interval", interval: $particleRefreshInterval)
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }

    private var pollsContent: some View {
        Form {
            Section("Data Source") {
                Toggle("Enable Election Poll Data", isOn: $showElectionPolls)
            }
            Section("Scope") {
                Picker("Poll Scope", selection: $electionPollScope) {
                    Text("Federal").tag(0)
                    Text("State").tag(1)
                }
                .pickerStyle(.radioGroup)
            }
            Section("Refresh") {
                RefreshRatePicker(label: "Update Interval", interval: $surveyRefreshInterval)
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }

    private var aboutContent: some View {
        VStack(spacing: 12) {
            Spacer()

            Text("Dashboard of Doom")
                .font(.title2)
                .fontWeight(.semibold)

            Text(
                "Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0") (\(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"))"
            )
            .font(.subheadline)
            .foregroundColor(.secondary)

            Text(
                "A macOS menu bar application providing real-time environmental and public health data for Germany. Integrates weather, air quality, water levels, radiation, COVID-19 statistics, and election polls from official German federal APIs."
            )
            .font(.caption)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 40)

            Spacer()

            Text("© 2025 Heiko Panjas. All rights reserved.")
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

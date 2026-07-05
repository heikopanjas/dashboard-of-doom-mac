import DoomKit
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
                        isSelected: self.selectedTab == tab,
                        action: { self.selectedTab = tab }
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 6)

            Divider()

            // Content
            Group {
                switch self.selectedTab {
                    case .general:
                        GeneralSettingsView(alwaysUseDarkTheme: self.$alwaysUseDarkTheme)
                    case .weather:
                        WeatherSettingsView(showWeather: self.$showWeather, refreshInterval: self.$weatherRefreshInterval)
                    case .covid:
                        CovidSettingsView(showCovid: self.$showCovid, refreshInterval: self.$covidRefreshInterval)
                    case .level:
                        LevelSettingsView(
                            showLevels: self.$showLevels, nearestSensor: self.$nearestLevelSensor, refreshInterval: self.$levelRefreshInterval)
                    case .radiation:
                        RadiationSettingsView(showRadiation: self.$showRadiation, refreshInterval: self.$radiationRefreshInterval)
                    case .particles:
                        ParticlesSettingsView(
                            showParticles: self.$showParticles, nearestSensor: self.$nearestParticleSensor,
                            refreshInterval: self.$particleRefreshInterval)
                    case .polls:
                        PollsSettingsView(
                            showElectionPolls: self.$showElectionPolls, pollScope: self.$electionPollScope,
                            refreshInterval: self.$surveyRefreshInterval)
                    case .about:
                        AboutSettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: 660, height: 400)
        .background(Color(light: .white, dark: Color(hex: "#000000")))
        .onChange(of: self.nearestLevelSensor) { _, _ in
            if let presenter = self.levelPresenter {
                Task {
                    await AppProcessControl.shared.refreshSubscription(presenterId: presenter.id)
                }
            }
        }
        .onChange(of: self.nearestParticleSensor) { _, _ in
            if let presenter = self.particlePresenter {
                Task {
                    await AppProcessControl.shared.refreshSubscription(presenterId: presenter.id)
                }
            }
        }
        .onChange(of: self.electionPollScope) { _, _ in
            if let presenter = self.surveyPresenter {
                Task {
                    await AppProcessControl.shared.refreshSubscription(presenterId: presenter.id)
                }
            }
        }
        .onChange(of: self.weatherRefreshInterval) { _, _ in
            Task {
                await AppProcessControl.shared.reregisterProcessPresenters(forIntervalKey: "weatherRefreshInterval")
            }
        }
        .onChange(of: self.covidRefreshInterval) { _, _ in
            Task {
                await AppProcessControl.shared.reregisterProcessPresenters(forIntervalKey: "covidRefreshInterval")
            }
        }
        .onChange(of: self.levelRefreshInterval) { _, _ in
            Task {
                await AppProcessControl.shared.reregisterProcessPresenters(forIntervalKey: "levelRefreshInterval")
            }
        }
        .onChange(of: self.radiationRefreshInterval) { _, _ in
            Task {
                await AppProcessControl.shared.reregisterProcessPresenters(forIntervalKey: "radiationRefreshInterval")
            }
        }
        .onChange(of: self.particleRefreshInterval) { _, _ in
            Task {
                await AppProcessControl.shared.reregisterProcessPresenters(forIntervalKey: "particleRefreshInterval")
            }
        }
        .onChange(of: self.surveyRefreshInterval) { _, _ in
            Task {
                await AppProcessControl.shared.reregisterProcessPresenters(forIntervalKey: "surveyRefreshInterval")
            }
        }
    }
}

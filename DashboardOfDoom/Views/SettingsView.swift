import SwiftUI

struct SettingsView: View {
    @AppStorage("showWeather") private var showWeather: Bool = true
    @AppStorage("showCovid") private var showCovid: Bool = true
    @AppStorage("showLevels") private var showLevels: Bool = true
    @AppStorage("showRadiation") private var showRadiation: Bool = true
    @AppStorage("showParticles") private var showParticles: Bool = true
    @AppStorage("showElectionPolls") private var showElectionPolls: Bool = true

    @AppStorage("nearestLevelSensor") private var nearestLevelSensor: Bool = false
    @AppStorage("nearestParticleSensor") private var nearestParticleSensor: Bool = false
    @AppStorage("electionPollScope") private var electionPollScope: Int = 1

    var body: some View {
        Form {
            Section("Data Sources") {
                Toggle("Weather", isOn: $showWeather)
                Toggle("COVID-19", isOn: $showCovid)
                Toggle("Water Levels", isOn: $showLevels)
                Toggle("Radiation", isOn: $showRadiation)
                Toggle("Particulate Matter", isOn: $showParticles)
                Toggle("Election Polls", isOn: $showElectionPolls)
            }

            Section("Sensor Preferences") {
                Toggle("Use nearest water level sensor", isOn: $nearestLevelSensor)
                    .help("When enabled, shows data from the closest water level sensor to your location")

                Toggle("Use nearest particle sensor", isOn: $nearestParticleSensor)
                    .help("When enabled, shows data from the closest air quality sensor to your location")
            }

            Section("Election Polls") {
                Picker("Scope", selection: $electionPollScope) {
                    Text("Federal Only").tag(0)
                    Text("State Only").tag(1)
                    Text("Both Federal and State").tag(2)
                }
                .pickerStyle(.radioGroup)
            }
        }
        .formStyle(.grouped)
        .frame(width: 450, height: 400)
        .navigationTitle("Settings")
    }
}

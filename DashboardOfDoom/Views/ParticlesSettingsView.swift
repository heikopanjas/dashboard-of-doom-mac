import SwiftUI

struct ParticlesSettingsView: View {
    @Binding var showParticles: Bool
    @Binding var nearestSensor: Bool
    @Binding var refreshInterval: Int

    var body: some View {
        Form {
            Section("Data Source") {
                Toggle("Enable Particulate Matter Data", isOn: self.$showParticles)
            }
            Section("Sensor") {
                Toggle("Use Nearest Sensor", isOn: self.$nearestSensor)
                    .help("When enabled, shows data from the closest air quality sensor to your location")
            }
            Section("Refresh") {
                RefreshRatePicker(label: "Update Interval", interval: self.$refreshInterval)
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }
}

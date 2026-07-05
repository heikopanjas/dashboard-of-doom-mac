import SwiftUI

struct LevelSettingsView: View {
    @Binding var showLevels: Bool
    @Binding var nearestSensor: Bool
    @Binding var refreshInterval: Int

    var body: some View {
        Form {
            Section("Data Source") {
                Toggle("Enable Water Level Data", isOn: self.$showLevels)
            }
            Section("Sensor") {
                Toggle("Use Nearest Sensor", isOn: self.$nearestSensor)
                    .help("When enabled, shows data from the closest water level sensor to your location")
            }
            Section("Refresh") {
                RefreshRatePicker(label: "Update Interval", interval: self.$refreshInterval)
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }
}

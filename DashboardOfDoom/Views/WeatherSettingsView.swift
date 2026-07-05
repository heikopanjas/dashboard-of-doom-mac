import SwiftUI

struct WeatherSettingsView: View {
    @Binding var showWeather: Bool
    @Binding var refreshInterval: Int

    var body: some View {
        Form {
            Section("Data Source") {
                Toggle("Enable Weather Data", isOn: self.$showWeather)
            }
            Section("Refresh") {
                RefreshRatePicker(label: "Update Interval", interval: self.$refreshInterval)
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }
}

import SwiftUI

struct RadiationSettingsView: View {
    @Binding var showRadiation: Bool
    @Binding var refreshInterval: Int

    var body: some View {
        Form {
            Section("Data Source") {
                Toggle("Enable Radiation Data", isOn: self.$showRadiation)
            }
            Section("Refresh") {
                RefreshRatePicker(label: "Update Interval", interval: self.$refreshInterval)
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }
}

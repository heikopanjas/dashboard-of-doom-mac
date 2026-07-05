import SwiftUI

struct CovidSettingsView: View {
    @Binding var showCovid: Bool
    @Binding var refreshInterval: Int

    var body: some View {
        Form {
            Section("Data Source") {
                Toggle("Enable COVID-19 Data", isOn: self.$showCovid)
            }
            Section("Refresh") {
                RefreshRatePicker(label: "Update Interval", interval: self.$refreshInterval)
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }
}

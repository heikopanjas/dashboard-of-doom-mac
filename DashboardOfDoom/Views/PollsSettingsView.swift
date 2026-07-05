import SwiftUI

struct PollsSettingsView: View {
    @Binding var showElectionPolls: Bool
    @Binding var pollScope: Int
    @Binding var refreshInterval: Int

    var body: some View {
        Form {
            Section("Data Source") {
                Toggle("Enable Election Poll Data", isOn: self.$showElectionPolls)
            }
            Section("Scope") {
                Picker("Poll Scope", selection: self.$pollScope) {
                    Text("Federal").tag(0)
                    Text("State").tag(1)
                }
                .pickerStyle(.radioGroup)
            }
            Section("Refresh") {
                RefreshRatePicker(label: "Update Interval", interval: self.$refreshInterval)
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }
}

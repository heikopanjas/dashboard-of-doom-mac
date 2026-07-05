import LaunchAtLogin
import SwiftUI

struct GeneralSettingsView: View {
    @Binding var alwaysUseDarkTheme: Bool

    var body: some View {
        Form {
            Section("Application") {
                LaunchAtLogin.Toggle("Launch at Login")
            }
            Section("Appearance") {
                Toggle("Always Use Dark Theme", isOn: self.$alwaysUseDarkTheme)
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }
}

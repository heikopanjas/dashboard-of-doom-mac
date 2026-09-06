import DoomKitLocation
import SwiftUI

struct LocationSettingsView: View {
    @State private var state = AppLocation.shared.state

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Location").font(.headline)
            Text(self.authorizationText)
            Text(self.state.origin == .fallback ? "Using the default location: HKW, Berlin." : "Using your current location.")
                .font(.footnote).foregroundStyle(.secondary)
            Text("Nearby data updates as you move. Allow Always in iOS Settings for background location updates.")
                .font(.footnote).foregroundStyle(.secondary)
            Button("Open iOS Settings") {
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                UIApplication.shared.open(url)
            }
        }
        .padding()
        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 10))
        .task {
            for await state in AppLocation.shared.updates() {
                guard Task.isCancelled == false else { return }
                self.state = state
            }
        }
    }

    private var authorizationText: String {
        switch self.state.authorization {
            case .denied: return "Location access is denied."
            case .restricted: return "Location access is restricted."
            case .notDetermined: return "Location permission has not been granted."
            case .authorized:
                switch self.state.authorizationScope {
                    case .always: return "Location access: Always."
                    case .whenInUse: return "Location access: While Using the App."
                    case .unknown: return "Location access is allowed."
                }
        }
    }
}

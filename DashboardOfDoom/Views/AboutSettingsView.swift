import SwiftUI

struct AboutSettingsView: View {
    var body: some View {
        VStack(spacing: 12) {
            Spacer()

            Text("Dashboard of Doom")
                .font(.title2)
                .fontWeight(.semibold)

            Text(
                "Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0") (\(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"))"
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)

            Text(
                "A macOS menu bar application providing real-time environmental and public health data for Germany. Integrates weather, air quality, water levels, radiation, COVID-19 statistics, and election polls from official German federal APIs."
            )
            .font(.caption)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 40)

            Spacer()

            Text("© 2025 Heiko Panjas. All rights reserved.")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

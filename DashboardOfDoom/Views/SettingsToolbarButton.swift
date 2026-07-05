import SwiftUI

struct SettingsToolbarButton: View {
    let tab: SettingsTab
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: tab.icon)
                    .font(.system(size: 20))
                    .frame(height: 24)
                Text(tab.rawValue)
                    .font(.system(size: 10))
            }
            .frame(width: 64, height: 46)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isSelected ? Color.primary.opacity(0.1) : Color.clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .focusable(false)
        .foregroundColor(.primary)
    }
}

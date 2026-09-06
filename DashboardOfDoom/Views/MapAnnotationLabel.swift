import DoomKitProcess
import DoomKitTools
import SwiftUI

/// Shared with the screen-space solver, including both layers of padding.
struct MapAnnotationLabel: View {
    let selector: ProcessSelector
    let icon: String
    let faceplate: String
    var backgroundOpacity: Double = 0.5

    var body: some View {
        HStack {
            Image(systemName: self.icon)
                .accessibilityHidden(true)
            Text(self.faceplate)
        }
        .frame(width: AnnotationLayout.labelSize.width - 20, height: AnnotationLayout.labelSize.height - 10)
        .padding(5)
        .padding(.horizontal, 5)
        .background(
            RoundedRectangle(cornerRadius: 13)
                .fill(Color.faceplate(selector: self.selector))
                .opacity(self.backgroundOpacity)
        )
        .foregroundStyle(.black)
        .accessibilityElement(children: .combine)
    }
}

import SwiftUI

struct ContentPanelStyle: DisclosureGroupStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            Button {
                configuration.isExpanded.toggle()
            } label: {
                HStack {
                    configuration.label
                    Spacer()
                    Image(systemName: configuration.isExpanded ? "arrowtriangle.down" : "arrowtriangle.forward")
                        .fontWeight(.light)
                }
                .padding(.vertical, 8)
                .padding(.trailing)
                .frame(height: 17)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if configuration.isExpanded {
                configuration.content
                    .padding(.leading)
            }
        }
        .focusable(false)
    }
}

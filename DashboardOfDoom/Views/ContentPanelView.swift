import SwiftUI

struct ContentPanelView<Content: View>: View {
    let label: String
    let icon: String
    @State private var isExpanded: Bool = false
    @ViewBuilder var content: () -> Content

    var body: some View {
        DisclosureGroup(
            isExpanded: $isExpanded,
            content: {
                content()
            },
            label: {
                HStack {
                    Image(systemName: self.icon)
                        .imageScale(.large)
                        .frame(width: 23)
                    Text(self.label)
                }
                .padding()
            }
        )
        .disclosureGroupStyle(ContentPanelStyle())
    }
}

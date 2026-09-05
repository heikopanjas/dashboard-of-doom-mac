import SwiftUI

struct PointOfInterestSettingsView: View {
    let presenter: PointOfInterestPresenter

    var body: some View {
        Form {
            Toggle(
                "Show points of interest",
                isOn: Binding(
                    get: { self.presenter.isEnabled }, set: { self.presenter.setEnabled($0) }))
            ForEach(PointOfInterestCategory.allCases, id: \.self) { category in
                Toggle(
                    isOn: Binding(
                        get: { self.presenter.categories.contains(category) },
                        set: { self.presenter.setCategory(category, enabled: $0) })
                ) {
                    Label {
                        Text(category.title)
                    } icon: {
                        Image(systemName: category.symbol).foregroundStyle(category.color)
                    }
                }
                .disabled(self.presenter.isEnabled == false)
            }
            Text("Places within 6.7 km refresh hourly or after moving 1 km. Map data © OpenStreetMap contributors.")
                .font(.caption).foregroundStyle(.secondary)
        }
        .formStyle(.grouped)
    }
}

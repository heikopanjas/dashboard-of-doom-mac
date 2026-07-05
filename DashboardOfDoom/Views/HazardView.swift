import DoomKit
import SwiftUI
import WebKit

struct HazardView: View {
    @Environment(HazardPresenter.self) private var presenter

    var body: some View {
        VStack {
            ForEach(self.presenter.hazards, id: \.id) { value in
                VStack {
                    Spacer()
                    if let placemark = value.placemark {
                        HStack {
                            Image(systemName: "safari")
                            Text(placemark)
                            Spacer()
                        }
                        .font(.footnote)
                        .foregroundStyle(.tint)
                    }
                    Spacer()
                    HStack {
                        Text(value.headline)
                            .font(.headline)
                        Spacer()
                    }
                    .foregroundStyle(.tint)
                    Spacer()
                    HStack {
                        Text(value.description)
                        Spacer()
                    }
                    .font(.footnote)
                    .foregroundStyle(.tint)
                    Spacer()
                }
                Divider()
            }
        }
    }
}

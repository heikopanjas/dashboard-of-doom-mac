import DoomKit
import SwiftUI
import WebKit

struct HazardView: View {
    @Environment(HazardPresenter.self) private var presenter

    var body: some View {
        VStack {
            if let values = presenter.hazards  {
                ForEach(values, id: \.id) { value in
                    VStack {
                        Spacer()
                        if let placemark = value.placemark {
                            HStack {
                                Image(systemName: "safari")
                                Text(placemark)
                                Spacer()
                            }
                            .font(.footnote)
                            .foregroundColor(.accentColor)
                        }
                        Spacer()
                        HStack {
                            Text(value.headline)
                                .font(.headline)
                            Spacer()
                        }
                        .foregroundColor(.accentColor)
                        Spacer()
                        HStack {
                            Text(value.description)
                            Spacer()
                        }
                        .font(.footnote)
                        .foregroundColor(.accentColor)
                        Spacer()
                    }
                    Divider()
                }
            }
        }
    }
}

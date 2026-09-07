import DoomKitProcess
import Charts
import SwiftUI

struct LevelView: View {
    @Environment(LevelPresenter.self) private var presenter

    var body: some View {
        VStack {
            if presenter.timestamp == nil {
                ActivityIndicator()
            }
            else {
                #if os(macOS)
                HStack(alignment: .bottom) {
                    HStack {
                        Image(systemName: "safari")
                        Text(String(format: "%@", self.presenter.placemark))
                    }
                    Spacer()
                    Text("Last update: \(Date.absoluteString(date: self.presenter.timestamp))")
                        .foregroundColor(.gray)
                }
                .font(.footnote)
                #else
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "safari")
                        Text(String(format: "%@", self.presenter.placemark))
                        Spacer()
                    }
                    .foregroundColor(.accentColor)
                    HStack {
                        Text("Last update: \(Date.absoluteString(date: self.presenter.timestamp))")
                        Spacer()
                    }
                    .foregroundColor(.gray)
                }
                .font(.footnote)
                #endif

                let selectors = ProcessSelector.Water.allCases.filter {
                    self.presenter.isAvailable(selector: .water($0))
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(selectors, id: \.self) { selector in
                        VStack {
                            LevelChartView(selector: .water(selector))
                        }
                        .frame(height: 167)
                    }
                }
            }
        }
    }
}

import Charts
import DoomKit
import SwiftUI

struct SurveyView: View {
    @Environment(SurveyPresenter.self) private var presenter

    var body: some View {
        VStack {
            if self.presenter.timestamp == nil {
                ActivityIndicator()
            }
            else {
                #if os(macOS)
                HStack(alignment: .bottom) {
                    HStack {
                        Image(systemName: "safari")
                        Text(self.presenter.placemark)
                    }
                    Spacer()
                    Text("Last update: \(Date.absoluteString(date: self.presenter.timestamp))")
                        .foregroundStyle(.gray)
                }
                .font(.footnote)
                #else
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "safari")
                        Text(self.presenter.placemark)
                        Spacer()
                    }
                    .foregroundStyle(.tint)
                    HStack {
                        Text("Last update: \(Date.absoluteString(date: self.presenter.timestamp))")
                        Spacer()
                    }
                    .foregroundStyle(.gray)
                }
                .font(.footnote)
                #endif

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(ProcessSelector.Survey.allCases, id: \.self) { selector in
                        if self.presenter.isAvailable(selector: .survey(selector), threshold: 5.0) {
                            VStack {
                                SurveyChartView(selector: .survey(selector))
                            }
                            .frame(height: 167)
                        }
                    }
                }
            }
        }
    }
}

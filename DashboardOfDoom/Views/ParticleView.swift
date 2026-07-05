import Charts
import DoomKit
import SwiftUI

struct ParticleView: View {
    @Environment(ParticlePresenter.self) private var presenter

    var body: some View {
        VStack {
            if self.presenter.sensor?.timestamp == nil {
                ActivityIndicator()
            }
            else {
                #if os(macOS)
                HStack(alignment: .bottom) {
                    HStack {
                        Image(systemName: "safari")
                        Text(String(format: "%@", self.presenter.sensor?.placemark ?? "<Unknown>"))
                    }
                    Spacer()
                    Text("Last update: \(Date.absoluteString(date: self.presenter.sensor?.timestamp))")
                        .foregroundStyle(.gray)
                }
                .font(.footnote)
                #else
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "safari")
                        Text(String(format: "%@", self.presenter.placemark))
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
                    ForEach(ProcessSelector.Particle.allCases, id: \.self) { selector in
                        if self.presenter.isAvailable(selector: .particle(selector)) {
                            VStack {
                                ParticleChartView(selector: .particle(selector))
                            }
                            .frame(height: 167)
                        }
                    }
                }
            }
        }
    }
}

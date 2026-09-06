import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let html: String

    func makeUIView(context: Context) -> WKWebView { WKWebView() }
    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.loadHTMLString(html, baseURL: nil)
    }
}

struct SimpleWebView: UIViewRepresentable {
    let htmlContent: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.isScrollEnabled = false // Disable scrolling if you want
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.loadHTMLString(htmlContent, baseURL: nil)
    }
}

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

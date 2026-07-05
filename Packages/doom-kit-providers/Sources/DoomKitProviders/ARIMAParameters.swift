import Foundation

/// ARIMA model parameters
struct ARIMAParameters {
    let p: Int
    let d: Int
    let q: Int

    init(p: Int = 1, d: Int = 1, q: Int = 1) {
        self.p = max(0, p)
        self.d = max(0, d)
        self.q = max(0, q)
    }
}

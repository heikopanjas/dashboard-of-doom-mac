import SwiftUI

enum SettingsTab: String, CaseIterable {
    case general = "General"
    case weather = "Weather"
    case covid = "COVID-19"
    case level = "Level"
    case radiation = "Radiation"
    case particles = "Particles"
    case polls = "Polls"
    case about = "About"

    var icon: String {
        switch self {
            case .general: return "gear"
            case .weather: return "cloud.sun"
            case .covid: return "facemask"
            case .level: return "water.waves"
            case .radiation: return "atom"
            case .particles: return "aqi.medium"
            case .polls: return "chart.bar"
            case .about: return "info.circle"
        }
    }
}

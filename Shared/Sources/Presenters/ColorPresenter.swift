import Foundation
import SwiftUI

@Observable class ColorPresenter {
    static let accentNames = [
        "red", "orange", "yellow", "green", "mint", "teal", "cyan", "blue", "indigo", "purple", "pink", "brown", "white", "gray", "black"
    ]
    static let accentColors: [Color] = [
        .red, .orange, .yellow, .green, .mint, .teal, .cyan, .blue, .indigo, .purple, .pink, .brown, .white, .gray, .black
    ]
    var tintColor: Color
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let name = defaults.string(forKey: "selectedColor") ?? "cyan"
        let index = Self.accentNames.firstIndex(of: name) ?? 6
        self.tintColor = Self.accentColors[index]
    }

    func selectAccent(_ name: String) {
        guard let index = Self.accentNames.firstIndex(of: name) else { return }
        self.defaults.set(name, forKey: "selectedColor")
        self.tintColor = Self.accentColors[index]
    }
    var colorScheme: ColorScheme {
        return UserDefaults.standard.bool(forKey: "enableDarkTheme") == true ? .dark : .light
    }
}

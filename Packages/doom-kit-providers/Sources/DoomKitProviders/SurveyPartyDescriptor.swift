import Foundation

public struct SurveyPartyDescriptor {
    public let shortcut: String
    public let name: String

    public init(shortcut: String, name: String) {
        self.shortcut = shortcut
        self.name = name
    }
}

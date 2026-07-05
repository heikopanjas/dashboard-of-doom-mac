import Foundation

public enum ProcessMetadataValue: Sendable, Hashable {
    case string(String)
    case double(Double)
    case int(Int)
    case bool(Bool)
    case array([ProcessMetadataValue])
    case dictionary([String: ProcessMetadataValue])
    case null
}

public typealias ProcessMetadata = [String: ProcessMetadataValue]

extension ProcessMetadata {
    public init(_ stringPairs: [String: String]) {
        self = stringPairs.mapValues { ProcessMetadataValue.string($0) }
    }

    public func string(for key: String) -> String? {
        if case .string(let value)? = self[key] {
            return value
        }
        return nil
    }
}

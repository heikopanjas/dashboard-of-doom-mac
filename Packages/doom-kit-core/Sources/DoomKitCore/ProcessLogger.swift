import Foundation

public struct ProcessLogger: Sendable {
    public var debug: @Sendable (String) -> Void
    public var info: @Sendable (String) -> Void
    public var warning: @Sendable (String) -> Void
    public var error: @Sendable (String) -> Void

    public init(
        debug: @escaping @Sendable (String) -> Void = { _ in },
        info: @escaping @Sendable (String) -> Void = { _ in },
        warning: @escaping @Sendable (String) -> Void = { _ in },
        error: @escaping @Sendable (String) -> Void = { _ in }
    ) {
        self.debug = debug
        self.info = info
        self.warning = warning
        self.error = error
    }

    public static let noop = ProcessLogger()
}

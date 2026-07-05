import Foundation

public struct ProcessRuntimeDependencies: Sendable {
    public var waitUntilReady: @Sendable () async -> Void
    public var logger: ProcessLogger

    public init(
        waitUntilReady: @escaping @Sendable () async -> Void = {},
        logger: ProcessLogger = .noop
    ) {
        self.waitUntilReady = waitUntilReady
        self.logger = logger
    }

    public static let `default` = ProcessRuntimeDependencies()
}

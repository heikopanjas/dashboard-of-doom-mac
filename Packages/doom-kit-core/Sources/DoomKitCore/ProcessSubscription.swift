import Foundation

public struct ProcessSubscription: Identifiable, Sendable {
    public let id: UUID
    public let timeout: TimeInterval
    public var remaining: TimeInterval
    public let refresh: @Sendable (Location) async -> Void

    public init(
        id: UUID,
        timeout: TimeInterval,
        refresh: @escaping @Sendable (Location) async -> Void
    ) {
        self.id = id
        self.timeout = (timeout >= 60) ? timeout : 60
        self.remaining = self.timeout
        self.refresh = refresh
    }

    public mutating func update(tick: TimeInterval) -> Void {
        self.remaining -= tick
    }

    public func isPending() -> Bool {
        return self.remaining <= 0
    }

    public mutating func reset() -> Void {
        self.remaining = self.timeout
    }
}

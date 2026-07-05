import Foundation

public struct ProcessPresentationSnapshot: Sendable {
    public let measurements: [ProcessSelector: [ProcessValue<Dimension>]]
    public let current: [ProcessSelector: ProcessValue<Dimension>]
    public let faceplate: [ProcessSelector: String]
    public let range: [ProcessSelector: ClosedRange<Double>]
    public let trend: [ProcessSelector: String]
    public let metadata: ProcessMetadata

    public init(
        measurements: [ProcessSelector: [ProcessValue<Dimension>]],
        current: [ProcessSelector: ProcessValue<Dimension>],
        faceplate: [ProcessSelector: String],
        range: [ProcessSelector: ClosedRange<Double>],
        trend: [ProcessSelector: String],
        metadata: ProcessMetadata = [:]
    ) {
        self.measurements = measurements
        self.current = current
        self.faceplate = faceplate
        self.range = range
        self.trend = trend
        self.metadata = metadata
    }
}

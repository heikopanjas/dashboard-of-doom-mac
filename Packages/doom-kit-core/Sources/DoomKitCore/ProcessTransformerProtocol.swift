import Foundation

public protocol ProcessTransformerProtocol {
    func render(sensor: ProcessSensor) throws -> ProcessPresentationSnapshot
}

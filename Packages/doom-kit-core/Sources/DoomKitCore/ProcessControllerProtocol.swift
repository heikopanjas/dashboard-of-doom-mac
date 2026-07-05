import Foundation

public protocol ProcessControllerProtocol {
    func refreshData(for location: Location) async throws -> [ProcessSensor]
}

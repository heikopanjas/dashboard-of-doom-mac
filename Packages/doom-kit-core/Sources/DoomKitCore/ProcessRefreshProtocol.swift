import Foundation

public protocol ProcessRefreshProtocol: Identifiable where ID == UUID {
    func refreshData(location: Location) async
}

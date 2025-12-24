import Foundation

public protocol ProcessRefreshable: Identifiable where ID == UUID {
    func refreshData(location: Location) async
}


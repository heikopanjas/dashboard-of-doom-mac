import DoomKit
import Foundation

struct ProcessPresenterRegistration {
    let presenter: any ProcessRefreshProtocol
    let refreshIntervalKey: String
    let defaultMinutes: TimeInterval
}

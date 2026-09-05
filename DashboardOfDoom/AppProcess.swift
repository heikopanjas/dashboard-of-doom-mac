import DoomKitProcess
import DoomKitNetwork

@MainActor
enum AppProcess {
    static let shared: ProcessCoordinator = {
        let coordinator = ProcessCoordinator(locationManager: AppLocation.shared, networkManager: NetworkManager.shared)
        coordinator.start()
        return coordinator
    }()
}

import UIKit

@MainActor
final class IOSAppDelegate: NSObject, UIApplicationDelegate {
    let runtime = IOSAppRuntime()

    func application(
        _ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        self.runtime.lifecycle.start()
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        self.runtime.lifecycle.enteredBackground()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        self.runtime.lifecycle.becameActive()
    }
}

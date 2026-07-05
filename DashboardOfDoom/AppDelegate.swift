import AppKit
import DoomKit
import Observation
import SwiftUI

@Observable
class AppDelegate: NSObject, NSApplicationDelegate {
    var settingsPanel: NSPanel?
    private var themeObserver: NSObjectProtocol?

    var levelPresenter: LevelPresenter?
    var particlePresenter: ParticlePresenter?
    var surveyPresenter: SurveyPresenter?

    func applicationDidFinishLaunching(_ notification: Notification) {
        self.updateAppearance()

        self.themeObserver = NotificationCenter.default.addObserver(
            forName: UserDefaults.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateAppearance()
        }
    }

    func updateAppearance() {
        let alwaysUseDarkTheme = UserDefaults.standard.bool(forKey: "alwaysUseDarkTheme")
        let useDark = UserDefaults.standard.object(forKey: "alwaysUseDarkTheme") == nil ? true : alwaysUseDarkTheme
        NSApp.appearance = useDark ? NSAppearance(named: .darkAqua) : nil
    }

    func showSettings() {
        DispatchQueue.main.async {
            NSRunningApplication.current.activate(options: [.activateAllWindows])

            if let panel = self.settingsPanel {
                panel.level = .popUpMenu
                panel.makeKeyAndOrderFront(nil)
                panel.orderFrontRegardless()
                NSApp.activate(ignoringOtherApps: true)
                return
            }

            let settingsView = SettingsView(
                levelPresenter: self.levelPresenter,
                particlePresenter: self.particlePresenter,
                surveyPresenter: self.surveyPresenter
            )
            let hostingController = NSHostingController(rootView: settingsView)
            hostingController.view.frame = NSRect(x: 0, y: 0, width: 660, height: 400)

            let panel = NSPanel(
                contentRect: NSRect(x: 0, y: 0, width: 660, height: 400),
                styleMask: [.titled, .closable, .nonactivatingPanel],
                backing: .buffered,
                defer: false
            )

            panel.title = "Settings"
            panel.contentViewController = hostingController
            panel.center()
            panel.isReleasedWhenClosed = false
            panel.level = .popUpMenu
            panel.hidesOnDeactivate = false
            panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]

            self.settingsPanel = panel

            NSApp.activate(ignoringOtherApps: true)
            panel.makeKeyAndOrderFront(nil)
            panel.orderFrontRegardless()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                NSApp.activate(ignoringOtherApps: true)
                panel.orderFrontRegardless()
            }
        }
    }
}

import AppKit
import SwiftUI

@main
struct DashboardOfDoomApp: App {
    @State var weatherViewModel = WeatherPresenter()
    @State var forecastPresenter = ForecastPresenter()
    @State var covidPresenter = CovidPresenter()
    @State var levelPresenter = LevelPresenter()
    @State var radiationPresenter = RadiationPresenter()
    @State var particlePresenter = ParticlePresenter()
    @State var surveyPresenter = SurveyPresenter()
    @State var colorPresenter = ColorPresenter()

    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        MenuBarExtra {
            ContentView()
                .environment(weatherViewModel)
                .environment(forecastPresenter)
                .environment(covidPresenter)
                .environment(levelPresenter)
                .environment(radiationPresenter)
                .environment(particlePresenter)
                .environment(surveyPresenter)
                .environment(colorPresenter)
                .environment(appDelegate)
        } label: {
            Text(weatherViewModel.faceplate[.weather(.temperature)] ?? "n/a")
                .font(.system(.body, design: .monospaced))
        }
        .menuBarExtraStyle(.window)
    }
}

@Observable
class AppDelegate: NSObject, NSApplicationDelegate {
    var settingsPanel: NSPanel?
    private var themeObserver: NSObjectProtocol?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Start network monitoring immediately to ensure connectivity before API calls
        Task {
            await NetworkManager.shared.startMonitoring()
        }

        // Apply initial theme
        updateAppearance()

        // Observe theme setting changes
        themeObserver = NotificationCenter.default.addObserver(
            forName: UserDefaults.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateAppearance()
        }
    }

    func updateAppearance() {
        let alwaysUseDarkTheme = UserDefaults.standard.bool(forKey: "alwaysUseDarkTheme")
        // Default to true if key doesn't exist (first launch)
        let useDark = UserDefaults.standard.object(forKey: "alwaysUseDarkTheme") == nil ? true : alwaysUseDarkTheme
        NSApp.appearance = useDark ? NSAppearance(named: .darkAqua) : nil
    }

    func showSettings() {
        DispatchQueue.main.async {
            // Force activate the app first using NSRunningApplication
            NSRunningApplication.current.activate(options: [.activateAllWindows])

            if let panel = self.settingsPanel {
                // Panel already exists, just show it
                panel.level = .popUpMenu
                panel.makeKeyAndOrderFront(nil)
                panel.orderFrontRegardless()
                NSApp.activate(ignoringOtherApps: true)
                return
            }

            // Create new settings panel
            let settingsView = SettingsView()
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

            // Ensure visibility after a brief delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                NSApp.activate(ignoringOtherApps: true)
                panel.orderFrontRegardless()
            }
        }
    }
}

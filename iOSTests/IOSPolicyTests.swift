import DoomKitLocation
import DoomKitProcess
import Foundation
import Testing

@MainActor
struct IOSPolicyTests {
    @Test func lifecycleStartsOnceAndRefreshesOnlyAfterBackground() {
        var starts = 0
        var refreshes = 0
        let lifecycle = AppActivityLifecycle(start: { starts += 1 }, refresh: { refreshes += 1 })
        lifecycle.start()
        lifecycle.start()
        lifecycle.becameActive()
        lifecycle.becameActive()
        #expect(starts == 1)
        #expect(refreshes == 0)
        lifecycle.enteredBackground()
        lifecycle.enteredBackground()
        lifecycle.becameActive()
        lifecycle.becameActive()
        #expect(starts == 1)
        #expect(refreshes == 1)
        lifecycle.enteredBackground()
        lifecycle.becameActive()
        #expect(refreshes == 2)
    }

    @Test func accentSelectionSurvivesRelaunch() throws {
        let suite = "IOSPolicyTests.accent.\(UUID())"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let original = ColorPresenter(defaults: defaults)
        original.selectAccent("purple")
        let relaunched = ColorPresenter(defaults: defaults)
        #expect(relaunched.tintColor == original.tintColor)
        #expect(defaults.string(forKey: "selectedColor") == "purple")
    }

    @Test func legacyKeysAndPollVisibilityRemainIndependent() throws {
        let suite = "IOSPolicyTests.\(UUID())"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        #expect(SourcePreferences.waterKey == "showWater")
        #expect(SourcePreferences.pollsEnableKey == "enableElectionPolls")
        #expect(SourcePreferences.pollsEnabledByDefault == false)
        #expect(SourcePreferences.pollsVisible(defaults: defaults) == false)
        var registrations = 0
        var removals = 0
        let presenter = SurveyPresenter(
            defaults: defaults, register: { _, _ in registrations += 1 }, remove: { _ in removals += 1 }, fetch: { _ in [] })
        #expect(registrations == 0)
        defaults.set(true, forKey: "enableElectionPolls")
        NotificationCenter.default.post(name: UserDefaults.didChangeNotification, object: defaults)
        #expect(registrations == 1)
        #expect(SourcePreferences.pollsVisible(defaults: defaults) == true)
        defaults.set(false, forKey: "showElectionPolls")
        NotificationCenter.default.post(name: UserDefaults.didChangeNotification, object: defaults)
        #expect(registrations == 1)
        #expect(removals == 0)
        #expect(SourcePreferences.pollsVisible(defaults: defaults) == false)
        defaults.set(false, forKey: "enableElectionPolls")
        NotificationCenter.default.post(name: UserDefaults.didChangeNotification, object: defaults)
        #expect(removals == 1)
        withExtendedLifetime(presenter) {}
    }
}

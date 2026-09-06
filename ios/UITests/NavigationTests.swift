import XCTest

@MainActor
final class NavigationTests: XCTestCase {
    func testNavigationGesturesAndDensePOIs() {
        self.continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = ["--ui-fixture", "-enableElectionPolls", "YES", "-showPlaces", "YES", "-enableDarkTheme", "NO"]
        app.launch()
        XCTAssertTrue(app.buttons["Settings"].waitForExistence(timeout: 15))
        self.capture("home-2000")
        for label in ["Weather", "COVID-19", "Environment", "Particles", "Election Polls", "Settings"] {
            app.buttons[label].tap()
            XCTAssertTrue(app.buttons["Home"].exists)
            self.capture(label)
            if label != "Settings" {
                let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0.3, dy: 0.4))
                let end = app.coordinate(withNormalizedOffset: CGVector(dx: 0.7, dy: 0.4))
                start.press(forDuration: 0.5, thenDragTo: end)
            }
        }
        app.buttons["Home"].tap()
        XCUIDevice.shared.orientation = .landscapeLeft
        self.capture("landscape-2000")
        XCUIDevice.shared.orientation = .portrait
        app.terminate()
        app.launchArguments = [
            "--ui-fixture", "--poi-10000", "-enableElectionPolls", "YES", "-showPlaces", "YES", "-enableDarkTheme", "YES",
            "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"
        ]
        app.launch()
        XCTAssertTrue(app.buttons["Settings"].waitForExistence(timeout: 15))
        self.capture("home-dark-large-text-10000")
        XCUIDevice.shared.orientation = .landscapeLeft
        self.capture("landscape-dark-10000")
        XCUIDevice.shared.orientation = .portrait
    }

    private func capture(_ name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        self.add(attachment)
    }
}

import AppKit
import SwiftUI

/// Publishes the hosting `NSWindow` of the dashboard scene. SwiftUI assigns an
/// undocumented identifier ("dashboard-AppWindow-1") that has changed between
/// releases, so the window is registered explicitly instead of being searched for.
struct DashboardWindowAccessor: NSViewRepresentable {
    let onChange: (NSWindow?) -> Void

    func makeNSView(context: Context) -> NSView {
        let view = TrackingView()
        view.onChange = self.onChange
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) -> Void {}

    final class TrackingView: NSView {
        var onChange: ((NSWindow?) -> Void)?

        override func viewDidMoveToWindow() -> Void {
            super.viewDidMoveToWindow()
            self.onChange?(self.window)
        }
    }
}

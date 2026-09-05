# Recent Updates & Decisions

This file is the append-only log of project decisions and notable changes, maintained by coding agents following the `recent-updates` skill. Everything below the marker line is user-owned history: slopctl never overwrites it during init or merge.

<!-- {changelog} -->

### 2026-09-05 (v6.3.6, map collision score precision, 22:37)

- replaced area subtraction with nonnegative outside-strip clipping scores, ensuring contained labels score exactly zero.
- excluded negligible floating-point edge noise from overlap scoring without weakening comparator ordering.
- reproduced the unwanted-connector bug with fractional-coordinate tests and verified that genuine clipping still overrides the preferred anchor.
- rationale: rounding errors must not outweigh direct attachment or preserve unnecessary connector lines.
- version bump: 6.3.5 to 6.3.6, build 142 to 143 (PATCH - display correction).

### 2026-09-05 (v6.3.5, direct map label attachment, 22:23)

- restored direct above-right label attachment instead of leaving a clearance gap around each source dot.
- prioritized fewer connectors and natural anchors over retaining old placements, so startup and crowding offsets disappear when space opens up.
- retained geometry-only caching; text refreshes do not determine placement quality.
- added regression tests for direct attachment and removing obsolete connectors after visibility and viewport changes, plus a separated-location preview.
- rationale: labels should visibly belong to their dots and only use lines when displacement is required.
- version bump: 6.3.4 to 6.3.5, build 141 to 142 (PATCH - display correction).

### 2026-09-05 (v6.3.4, map label collision correction, 22:03)

- separated macos map labels using one ordered snapshot, native location dots, and a projected overlay with category-colored connectors.
- added a pure tools layout solver with bounded deterministic beam search, marker clearance, outward anchors, and a viewport grid fallback.
- favored stable placements across refreshes; cached by geometry and kept text updates independent of layout.
- moved projection outside rendering and deferred geometry changes in a cancellable view task to handle transient map registration; retained weather dots when labels are disabled.
- preserved label styling, selectors, region fitting, noninteractive maps, signing, entitlements, pins, and the unvalidated ios presentation.
- added ordinary-import geometry regression tests and deterministic crowded-map previews; validation evidence is recorded in package_validation.md.
- rationale: make crowded measurements readable without changing their geographic meaning or refresh behavior.
- version bump: 6.3.3 to 6.3.4, build 140 to 141 (PATCH - display correction).


### 2026-09-05 (v6.3.3, units tools and services extraction, 21:39)

- moved eight unit files into doom-kit-process and extracted eight utility files into doom-kit-tools and seven service files into doom-kit-services.
- kept tools independent of process models; measurement smoothing callers preserve original metadata and units while creating new value identities.
- exported synchronous sendable trace with mutex-protected formatting and output; retained original filtering and shared logger configuration.
- preserved all 25 static service fetch contracts with trailing injectable network managers and shared tools logging and geometry.
- added ordinary-import regression tests using captured numerical and request fixtures, fake network dependencies, and concurrent file logging.
- rationale: reuse units, tools, and api services across clients without changing app behavior, signing, preferences, or pinned dependencies.
- version bump: 6.3.2 to 6.3.3, build 139 to 140 (PATCH - complete internal refactor).


### 2026-09-05 (v6.3.2, process module expansion, 21:05)

- moved all ten remaining process files into doom-kit-process, with local location and network dependencies and public model/helper contracts.
- opened presenter and transformer bases for app subclasses; retained arbitrary metadata and weak, observation-excluded coordinator cleanup.
- made coordinator construction inactive and injectable; appprocess supplies managers and starts it at the existing first-presenter initialization point.
- retained fallback, first-measurement and settings refresh behavior, with cancellation generations and restart coverage.
- rationale: consolidate process contracts and lifecycle implementation in the agreed single module while preserving app behavior.
- version bump: 6.3.1 to 6.3.2, build 138 to 139 (PATCH - internal refactor).


### 2026-09-05 (v6.3.1, 20:40 CEST extract update packages)

- extracted local doom-kit-location, doom-kit-network, and doom-kit-process packages with swift tools 6.2 and swift 6 language mode; kept the app in swift 5 mode
- declared macos 15 and ios 26 package support; ios validation and integration remain deferred
- replaced location delegates and network notifications with bounded per-consumer state streams and explicit lifecycle ownership
- isolated the initial core location delegate behind an injectable provider; native live updates remain a follow-up with separate behavior validation
- consolidated raw and decoded network requests, added injectable monitoring and timing, and replaced readiness polling with bounded observation
- moved scheduling into an independent main-actor generic manager with uuid removal, registration replacement, and cancel/restart generations
- kept fallback, measured-location, startup, and settings policy in the app coordinator; added per-refresh transformers and cancellation checks before publication
- added deterministic package tests and documented cancellation, shutdown, restart, and injection contracts
- rationale: make update providers replaceable while fixing stale refresh publication and lifecycle leaks
- version bump: 6.3.0 to 6.3.1, build 138 (patch - internal extraction and refresh cancellation fixes)


### 2026-09-05 (v6.3.0, 19:54 CEST consolidate build script)

- made build.sh default to a signed debug build, with separate release and notarization modes
- made clean remove root build outputs and exit unless combined with a build mode
- regenerated the xcodegen project before builds and fixed output paths under .build
- required accepted notarization before stapling and repackaged the stapled app for distribution
- added mock-based script tests for routing, cleanup, and failure handling
- rationale: provide one predictable command for development and distribution workflows
- version bump: none; build tooling changes without application behavior changes

### 2026-09-05 (v6.3.0, 19:43 CEST migrate to xcodegen)

- made project.yml authoritative for the app target, build settings, dependency, and shared scheme
- preserved debug and release settings, signing, entitlements, app version 6.3.0, and build 137
- ignored generated project files while retaining the tracked package lockfile
- documented generation, signing configuration, and command-line builds
- rationale: maintain reproducible project configuration through xcodegen going forward
- version bump: none; build-system migration without application behavior changes

### 2026-09-05 (v6.3.0, 19:38 CEST instruction accuracy update)

- clarified swift language mode and the macos deployment target
- refreshed the technology status date and macos-specific guidance
- replaced unrelated commit examples and corrected the omega symbol name
- rationale: align agent guidance with project settings and remove copied examples
- version bump: none; documentation-only corrections

### 2026-09-05 (v6.3.0, consolidate project history)

- moved the historical updates from AGENTS.md into UPDATES.md, preserving all entries
- linked AGENTS.md to the consolidated log
- rationale: keep current instructions separate from project history
- version bump: none; documentation-only consolidation

### January 9, 2026 (ProcessManager Timer RunLoop Fix)
- **Critical Bug Fix**: Subscription system timer was never firing, causing data to never update after initial load
- **Root Cause**: `Timer.scheduledTimer` was called from inside a `Task` block in `ProcessManager.init()`. Tasks run on a cooperative thread pool where threads lack an active RunLoop, so the timer was scheduled but never fired
- **Solution**: Wrapped timer scheduling in `DispatchQueue.main.async` to ensure the timer is added to the main RunLoop
- **Files Changed**: `ProcessManager.swift`
- **Added Logging**: Added trace log in `updateSubscriptions()` to help verify timer is firing
- **Reasoning**: Foundation `Timer` requires an active RunLoop on its thread. The main thread always has an active RunLoop, ensuring reliable timer execution

### January 9, 2026 (Settings Reactivity - Sensor and Scope Options)
- **Bug Fix**: "Use Nearest Sensor" toggles (Level/Particles) and "Federal vs State" poll scope now trigger immediate data refresh
- **Root Cause**: Settings were only read during periodic data refresh, not when user changed them in settings window
- **Solution**: 
  - Added presenter references to `SettingsView` (`levelPresenter`, `particlePresenter`, `surveyPresenter`)
  - Added `.onChange` modifiers that call `ProcessManager.shared.refreshSubscription(subscriber:)` when settings change
  - Modified `AppDelegate` to store presenter references, passed from main App via `.onAppear`
- **Files Changed**: `SettingsView.swift`, `DashboardOfDoomApp.swift`
- **Reasoning**: When behavioral settings change (not just visibility), the data needs to be re-fetched with the new parameters. Direct presenter access enables immediate refresh

### January 9, 2026 (MapView Settings Reactivity Fix)
- **Bug Fix**: Map annotations and map region now update immediately when services are enabled/disabled in settings
- **Root Cause**: `MapView` was using direct `UserDefaults.standard.bool(forKey:)` calls which SwiftUI does not observe for changes
- **Solution**: Added `@AppStorage` property wrappers to `MapView` for all service visibility settings (`showWeather`, `showCovid`, `showLevels`, `showRadiation`, `showParticles`, `showElectionPolls`)
- **Map Region Updates**: Added `.onChange` modifiers that call `MapPresenter.shared.updateRegion()` when settings change, ensuring the map zooms to fit visible annotations
- **Technical Detail**: `@AppStorage` integrates with SwiftUI's observation system, triggering view re-renders when values change. The `updateMapRegion()` helper registers or removes presenter locations from the `MapPresenter` visible region
- **Reasoning**: Consistent use of `@AppStorage` across views that depend on the same settings ensures reactive UI updates without manual notification mechanisms

### January 9, 2026 (ContentView Header UI Simplification)
- **Header Title Display**: Light mode shows "Dashboard of Doom" text, dark mode shows the logo image (`dashboard-of-doom-logo`)
- **Direct Action Buttons**: Replaced dropdown menu with two direct action buttons in the header bar:
  - `ellipsis.circle` button → Opens settings window via `appDelegate.showSettings()`
  - `togglepower` button → Quits application via `NSApplication.shared.terminate(nil)`
- **Removed AppMenuView**: Deleted `Views/AppMenuView.swift` - buttons now implemented directly in `ContentView.swift`
- **UX Improvement**: Simplified interaction by eliminating popover menu, saving a click for common actions
- **Reasoning**: Direct buttons provide faster access to settings and quit functionality without needing a menu. Color scheme-aware header title maintains brand identity while optimizing for dark mode aesthetics

### December 24, 2025 (Settings Window Implementation)
- **Settings Window Architecture**: Implemented NSPanel-based settings window for menu bar extra application
- **Window Ordering Solution**: Used NSPanel with .popUpMenu level and NSRunningApplication activation to ensure settings window appears in front
- **AppDelegate Environment Injection**: Made AppDelegate @Observable and passed through SwiftUI environment to access from menu bar extra views
- **Technical Details**: SwiftUI's Settings scene incompatible with menu bar extras for proper window ordering. NSPanel with NSHostingController provides reliable control over window levels and activation
- **Implementation Pattern**: Settings persist via @AppStorage directly in SettingsView, no presenter needed. Panel reused across invocations via persistent AppDelegate property
- **Reasoning**: Menu bar extras lack parent windows for activation context. Direct NSPanel management with aggressive activation (NSRunningApplication.current.activate) and high window level (.popUpMenu) ensures settings appear reliably in front of other windows

### November 4, 2025 (Evening Update - Build System)
- **Build Configuration**: Added comprehensive .gitignore file for Xcode project
- **Source Control**: Implemented proper ignore patterns for macOS development including xcuserdata, DerivedData, build artifacts, Swift Package Manager files, dependency managers, fastlane outputs, macOS system files, IDE configurations, and temporary files
- **Reasoning**: Essential for maintaining clean repository state, preventing accidental commits of user-specific settings, build artifacts, and system files. Follows Xcode and Swift community best practices for version control

### November 4, 2025 (Evening Update - README)
- **README.md Modernization**: Updated README.md to reflect macOS-only repository status
- **Platform Focus**: Removed iOS-specific content, badges, and installation instructions
- **Repository Structure**: Updated project structure diagram to show actual macOS-only file organization
- **Installation Updates**: Changed clone URL to heikopanjas/dashboard-of-doom-mac and simplified setup steps for single-platform development
- **Feature Enhancement**: Expanded macOS menu bar application features section with detailed system integration capabilities
- **Architecture Simplification**: Removed cross-platform architecture references, focused on MVP pattern for menu bar apps
- **Reasoning**: After separating repositories, README.md needed comprehensive updates to accurately represent the macOS-only codebase, remove iOS references, and provide clear installation instructions for the new repository location

### November 4, 2025 (Evening Update)
- **Repository Split**: Updated AGENTS.md to reflect macOS-only repository status after separation from iOS codebase
- **Platform Focus**: Removed cross-platform references and iOS-specific content, emphasizing macOS menu bar application architecture
- **Structure Clarification**: Updated Repository Structure, Platform Architecture, Platform-Specific Considerations, Code Organization, and Maintenance Guidelines sections to reflect single-platform focus
- **Reasoning**: The project has been split into separate iOS and macOS repositories. This macOS repository now contains a dedicated menu bar application with similar business logic patterns but platform-specific implementations. Documentation needed to accurately reflect this architectural change and guide future development with correct platform context

### November 4, 2025
- **Documentation Consolidation**: Replaced full content in `.github/copilot-instructions.md` and `CLAUDE.md` with simple references to `AGENTS.md`
- **Implementation Accuracy Update**: Synchronized AGENTS.md with actual codebase implementation details including iOS 26.0+ deployment target, WeatherKit integration, URLSession retry extensions, implemented utilities (ARIMA, MovingAverage, HaversineDistance, PointInPolygon, PolygonProximityCalculator, OSMUtilities, MathematicalSymbols, Trace), and accurate data source listings
- **Git Workflow Enhancement**: Integrated comprehensive commit message guidelines into Development Workflow section with detailed conventional commits format, character limits, special character safety rules, and practical examples to prevent terminal crashes and ensure clean git history
- **Reasoning**: Completed the consolidation process started on November 2nd by removing duplicate content from both agent-specific files and establishing AGENTS.md as the single source of truth. Updated technical specifications to match the current production codebase, ensuring documentation accurately reflects implemented architecture patterns and available utilities. Enhanced git workflow documentation to provide clear, actionable guidance for maintaining code quality and preventing common commit message issues

### November 2, 2025
- **Documentation Restructure**: Moved full instructions from `.github/copilot-instructions.md` to `AGENTS.md` at project root
- **Reasoning**: Centralized agent instructions in a dedicated file for easier maintenance and access, while keeping a simple reference in the GitHub Copilot-specific location

### 2025-10-05 (v0.1.0, initial setup)

- initial AGENTS.md setup
- established core coding standards and conventions
- defined repository structure and governance principles

### October 3, 2025
- **Documentation Cleanup**: Removed 'Contributing' section from README.md
- **Reasoning**: Streamlined documentation by removing contribution guidelines, focusing on core project documentation and features

### August 22, 2025
- **Documentation Enhancement**: Added macOS screenshots section to README.md showcasing application UI with four key views (main dashboard, forecast, environment, particles)
- **File Organization**: Moved copilot instructions from root directory to `.github/` for better project structure and GitHub integration
- **README Structure**: Enhanced documentation with professional screenshot layout and maintained existing comprehensive feature descriptions
- **Political Data Visualization**: Added election poll screenshots (state and federal) to showcase comprehensive political polling capabilities
- **Reasoning**: Improved project presentation for potential contributors and users while organizing development guidelines in standard GitHub directory structure

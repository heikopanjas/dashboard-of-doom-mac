# Recent Updates & Decisions

This file is the append-only log of project decisions and notable changes, maintained by coding agents following the `recent-updates` skill. Everything below the marker line is user-owned history: slopctl never overwrites it during init or merge.

<!-- {changelog} -->

### 2026-09-07 (macos v6.5.1, berlin bezirk exception for covid lookup, 15:50)

- discovered during manual verification of the prior entry: bkg's vg250 kreis layer models all of berlin as one feature, but rki reports covid data per berlin bezirk (12 boroughs, ids 11001 through 11012), since the bezirke are not independent gemeinden and never appear as separate features in any bkg layer; the whole-city id bkg returns for berlin is not even a valid rki district id, so covid data for any berlin location silently never loaded under the prior entry's implementation
- confirmed live against the current rki district list that this is the only such exception nationwide: 411 rki districts against germany's roughly 401 official kreise, with hamburg and every other city reporting as a single district like the rest of the country; the user's recollection was that hamburg had the same problem historically, but the live api disagrees today, so hamburg is left unhandled as a known possible gap rather than asserted fixed
- when bkg resolves a location to berlin's whole-city feature, fall through to a bundled dataset of the 12 bezirk boundaries (sourced from the amt fuer statistik berlin-brandenburg via a cc-by mirror) and re-resolve with the same point-in-polygon and nearest-edge logic already written for the general case, reusing rather than duplicating it
- add a second attribution line for the bezirk data alongside the bkg one
- validation: live end to end test at the user's actual location now correctly resolves to berlin mitte and successfully loads real incidence, cases, deaths, and recovered data, closing out the manual verification left pending in the previous entry; signed debug and release builds succeed, all 14 macos unit tests and nine build-script tests pass, ios build unaffected
- no version bump: continues the 6.5.1 patch from the previous entry

### 2026-09-07 (macos v6.5.1, covid district lookup via bkg wfs, 14:45)

- replace the osm overpass query used to resolve a location's covid district with a direct query against bkg's own vg250 wfs kreis layer
- rationale: the overpass approach queried four administrative tiers at once as a workaround for incomplete regionalschluessel tagging in osm, but never deduplicated the resulting candidates and only ever had centroid distance to rank them, since overpass's out center never returns real polygon geometry; a kreis and a nested gemeinde or stadtteil could both surface as separate candidates, and centroid distance is a poor proxy for which polygon a point actually falls inside near a kreis border
- bkg is the federal agency that owns the regionalschluessel scheme itself, so querying only its kreis layer returns exactly one feature per kreis with no tagging gaps to work around, and real multipolygon geometry enables genuine point-in-polygon containment for the first time, with a nearest-polygon-edge fallback for points outside every fetched candidate
- reused the app's existing point-in-polygon and nearest-point-on-polygon helpers and the geojson polygon-parsing pattern already established by the unrelated civil-protection hazard controller, rather than introducing new geometry primitives
- add a bkg attribution line to the macos about tab per its data licence; no equivalent about surface exists on ios today, so ios carries no attribution yet, a known gap rather than an in-scope fix
- no fallback to overpass if bkg is unreachable; district data is simply skipped that refresh cycle, matching how every other network failure in this controller already behaves
- validation: verified the bkg wfs endpoint, layer name, and response shape live before implementation; isPointInPolygon and filterItemsInPolygon unit tests still pass; manual verification of district resolution across several real locations, including a kreis-border case, and of graceful offline behavior is still pending
- version bump: 6.5.0 to 6.5.1 (patch - corrects existing district-resolution behavior, no new user-facing capability)

### 2026-09-07 (macos v6.5.0, combined sensors tab, 14:00)

- merge the level, radiation, and particles dashboard tabs into one sensors tab with a gauge icon, shortening the toolbar from seven tabs to five
- stack the three sections vertically in one scrolling view, each keeping its own placemark and last update header since these sensors can each sit at a different location
- also rename weather forecast to weather and particulate matter to particles in the toolbar, matching the existing settings tab labels
- rationale: level, radiation, and particles are all small, thematically related physical sensor readings, and did not need a dedicated toolbar slot each
- explicitly left the settings window untouched: it keeps separate level, radiation, and particles tabs with their own enable toggles and refresh intervals, since merging the dashboard display has no bearing on those per source settings
- validation: signed debug and release builds succeed, all 14 macos unit tests and nine build-script tests pass, ios build unaffected since it owns separate content and category views; manually verified all three sections render with distinct locations and data, dividers separate them, and settings still shows the three tabs unchanged
- no version bump: continues the current macos 6.5.0 cycle

### 2026-09-07 (macos v6.5.0, remove dashboard card chrome, 12:10)

- remove the card treatment from all six category views and from the home map, and delete the now unused dashboard card modifier
- keep only the outer padding on the home map, so it stays inset from the window edges with square corners and no border
- rationale: the card look was not wanted; charts read better bare on the plain background
- chart height stays at the fixed 167 points introduced in the previous entry; nothing here reintroduces height growth
- validation: signed debug and release builds succeed, all 14 macos unit tests and nine build-script tests pass, ios build unaffected; a clean build confirms no stale references to the deleted modifier, and the bare charts and padded map were verified visually
- no version bump: continues the current macos 6.5.0 cycle

### 2026-09-07 (macos v6.5.0, dashboard chart cards, 12:00)

- present each chart as a card with a faint fill, hairline border, and the app's existing corner radius of 13, via a new shared `dashboardCard` view modifier
- restore the fixed 167 point chart height and remove the geometryreader that had made charts grow with the window
- rationale: growing charts were not wanted; a card layout reads better than bare charts on a flat background
- apply the same outer padding to the home map as the category tabs, and give it the same card treatment with no inner padding so it fills its card edge to edge; this also restores the rounded map look the pre-tab layout had
- use concrete black and white opacities rather than the semantic primary color inside the light and dark color initializer, which resolves through a dynamic nscolor provider
- validation: signed debug and release builds succeed, all 14 macos unit tests and nine build-script tests pass, ios build unaffected; manually verified cards on every category tab, the fixed chart height on a single-chart category, the padded and clipped map, and card contrast in both light and dark themes
- two apparent regressions during verification were false alarms from accessibility scripting, not app defects: system events does not enumerate the settings nspanel and does not report frontmost correctly for this lsuielement app; the settings panel was confirmed visible through its own window frame
- no version bump: continues the current macos 6.5.0 cycle

### 2026-09-07 (macos v6.5.0, tabbed dashboard and resizable window, 11:40)

- replace the dashboard header title, logo, and settings button with a toolbar strip of category buttons matching the settings window pattern: home, weather forecast, covid-19, level, radiation, particulate matter, polls
- replace the stacked disclosure-group panels with a tab interface; selecting a toolbar button shows exactly one category full screen instead of scrolling through all of them at once
- make the home tab the full-size map view, filling the whole content area instead of a fixed 600 point strip above the panels
- make the dashboard window freely resizable with a 700x500 minimum and no maximum, instead of a fixed 800x859
- make each category's chart grid grow to fill available height via a per-view geometryreader, falling back to a 167 point minimum with scrolling once a category has too many selectors to fit
- extract the settings window's toolbar button into a shared `toolbartabbutton` view reused by both the settings panel and the new dashboard toolbar, removing the duplicate implementation
- truncate the full election party name on macos to one line, matching the existing ios truncation, since narrow resized windows would otherwise wrap it across three or four lines and crush the chart
- rationale: the previous single scrolling column did not scale to many data sources and could not be resized at all; the map was squeezed into a small preview instead of being a first class view
- bug caught during manual verification: wrapping each category view in an additional outer scrollview at the content-view level collapsed its internal geometryreader to zero height, rendering charts invisibly; fixed by letting each category view scroll only internally
- validation: signed debug and release builds succeed, all 14 macos unit tests and nine build-script tests pass, ios build unaffected since ios owns a separate content view and map sizing modifier; manually verified every toolbar tab, chart growth at a 3-selector category, chart scrolling at a 12-selector category, the 700x500 resize floor, unbounded growth to 1400x1000, and single-line party name truncation at the minimum width
- no version bump: continues the current macos 6.5.0 cycle

### 2026-09-07 (macos v6.5.0, menu bar menu and global hotkey, 11:10)

- replace the menu bar click-to-open dashboard popover with a status item menu: open dashboard, settings, about, quit
- promote the dashboard to a real swiftui window scene opened and focused via appdelegate, since the menu no longer hosts it directly
- add a user-configurable system-wide hotkey, default control-command-d, that toggles the dashboard window, using the sindresorhus keyboardshortcuts package
- move all nine presenters from app-struct state into appdelegate as non-optional properties so settings and the dashboard window both see live presenters regardless of which scene renders first
- add a shared settings-selection object so about opens the settings panel directly on its about tab while other entry points keep the last used tab
- remove the header quit button from the dashboard now that quit lives in the menu; keep the settings ellipsis button
- rationale: a single click-to-open popover left no room for settings, about, or a keyboard path to the app; the previous onAppear presenter handoff also broke silently once the dashboard stopped being the first rendered view
- validation: signed debug and release builds succeed, all 14 macos unit tests and nine build-script tests pass, ios build unaffected; manually verified the menu, dashboard window open and close, about routing, the recorder, and the global hotkey opening, closing, and raising the window from another frontmost app
- version bump: 6.4.3 to 6.5.0 (minor - new user-facing capability, no breaking change)

### 2026-09-07 (macos v6.4.3, archive paths, 01:37)

- fix macos archive finalization by applying output roots through xcode build-location preferences; keep direct build-setting overrides for ordinary debug and release builds
- rationale: command-line SYMROOT and OBJROOT flatten the archive layout and cause the missing BuildProductsPath error after successful compilation
- add regression assertions for archive routing; shell syntax, shellcheck, and all nine macos and ios build-script tests pass
- validation: reproduced the original archive error; repaired release archive, developer id export, and strict code signature verification pass; apple notarization upload awaits explicit approval
- no version bump: build tooling correction with unchanged app behavior and signing configuration

### 2026-09-07 (ios v6.3.0, ios display name, 01:12)

- explicitly set the ios display name in the source plist and product name in project.yml to Dashboard of Doom for iphone and ipad
- align the ios product name with the display name and update the simulator installation path; retain the module name, app identifier, signing, and background location configuration
- no version bump for this display metadata correction


### 2026-09-07 (macos v6.4.3, ios v6.3.0, platform directories, 00:54)

- group macos app sources, rendering tests, build-script tests, signing export configuration, and screenshots under macos
- group ios app sources, unit and ui tests, build-script tests, build entry point, and migration record under ios
- group common app sources and tests, five doomkit packages and their tests, and shared test tooling under shared
- retain repository entry points and the combined xcodegen specification at root; retain existing build output locations and dependency pins
- validation: all 187 tracked swift files preserved byte-for-byte, both signed debug app builds and signature checks pass, 14 macos tests, 17 ios tests, and nine build-script tests pass
- package validation: all five packages pass debug tests from their new paths; process, tools, and services also pass release tests
- no version bump: directory organization only, with unchanged app behavior


### 2026-09-07 (ios v6.3.0, narrower map labels, 00:39)

- enlarge ios label symbols from subheadline to title3 and reduce horizontal padding from ten to five points per side
- reduce label width from 142 to 132 points while retaining the 36-point height and callout measurement text
- validation: all 17 ios tests pass; longer particle and radiation readings visually checked over dense pois in light and dark appearances; signed build installed and launched on iphone
- included in the pending ios 6.3.0 (178) migration; no additional version bump


### 2026-09-07 (ios v6.3.0, compact map labels, 00:32)

- replace tall stacked ios map labels with 142 × 36-point horizontal labels, smaller symbols, and larger callout text
- rationale: physical iphone screenshots showed symbols dominating the labels and measurement text too small to read comfortably
- keep collision placement dimensions synchronized, preserve full voiceover values, and retain macos styling
- validation: all 17 ios tests pass, including dense poi rendering in light and dark appearances; signed iphone build succeeds
- included in the pending ios 6.3.0 (178) migration; no additional version bump


### 2026-09-07 (ios v6.3.0, correct ios app identity, 00:16)

- use the user-confirmed `com.panjas.dashboard-of-doom` app id for ios signing, simulator launching, tests, and current documentation
- rationale: the imported source's different identifier did not match the intended developer-account configuration and weatherkit authentication failed on the ipad
- validation: corrected signed debug build installed and launched on the physical ipad; jwt authentication errors no longer appear in its startup log; nine script tests, shell syntax, and shellcheck pass
- preserve the previous differently identified installation and its data; this correction remains part of the pending ios 6.3.0 (178) migration


### 2026-09-06 (macos v6.4.3, ios v6.3.0, ios modernization, 23:53)

- preserve the original ios develop history through a non-squashed subtree import under ios; generate both apps and test targets from root project.yml
- share controllers, presenters, models, transformers, extensions, and map/poi views with the five local doomkit packages; retain platform entry points, navigation, charts, settings, and assets
- retain ios always/best-accuracy background location, no automatic pauses, visible indicator, and the 100-metre movement filter; refresh each accepted ios movement and once after foreground return
- preserve legacy ios water and independent poll enable/visibility preferences, cancellation, disabled-source retention, and unconditional weather/forecast fetching
- port collision layout and batched poi rendering with ios label dimensions; keep the fallback map available without weatherkit and correct large-text label overflow
- add isolated ios tests, offline iphone/ipad ui fixtures, and build-ios.sh with explicit output paths and hkw simulator launching
- validation: all package debug tests and process/tools/services release tests pass on macos and ios simulator; 14 macos app tests, 17 ios app tests, and iphone/ipad ui checks pass; signed macos builds/signatures and unsigned ios simulator/device builds pass
- physical ios validation remains pending because this mac has no apple development certificate/private key; preserve existing app identities and weatherkit entitlements
- rationale: modernize the older ios app on the maintained data pipeline while retaining its platform behavior; see ios_migration.md for evidence and remaining device checks
- version bumps: macos 6.4.2 (146) to 6.4.3 (147), patch for internal consolidation; ios 6.2.0 (177) to 6.3.0 (178), minor for shared infrastructure, source controls, and restored configurable pois


### 2026-09-06 (v6.4.2, source refresh controls and readable labels, 22:38)

- remove and cancel disabled covid, water-level, radiation, particle, and poll subscriptions independently of popover visibility; retain successful values and refresh immediately on re-enable
- preserve unconditional weather and forecast refreshes and existing poi fetch controls
- stop cancelled controller work before dependent requests, station fallbacks, and geocoding
- use opaque environmental label backgrounds while the poi master switch is enabled, including loading and empty results; retain half opacity otherwise
- rationale: respect source switches and keep dense places from obscuring environmental labels without changing placement or rendering
- validation: 14 app tests passed, including parameterized coverage of all five sources; 16 process tests passed in both debug and release; unsigned app build passed; inspected rendered dense-poi overlays in light and dark appearances
- version bump: 6.4.1 (145) to 6.4.2 (146), patch for refresh and label readability fixes

### 2026-09-06 (v6.4.1, recover shared map data requests)

- coordinate all overpass requests with environmental discovery ahead of background pois
- fall back to a secondary public endpoint for availability failures and remember unavailable hosts
- respect shared rate-limit cooldowns without rotating endpoints on quota refusals
- retain official water-level data by choosing the nearest gauge when waterway discovery fails
- add injected regressions for scheduling, cancellation, fallback, cooldowns, and gauge recovery
- rationale: the unavailable primary overpass service blocked covid, water levels, and every poi category
- version bump: 6.4.0 (144) to 6.4.1 (145), patch for data-loading recovery

### 2026-09-05 (v6.4.0, points of interest restored, 23:30)

- restore all five poi categories with master and individual settings switches, enabled by default
- render every valid onscreen place with compact category symbols in one canvas, retaining apple places and environmental label priority
- retain the 6.7 km search radius, cache per category for an hour within 1 km, and bound requests to two across cancelled generations
- publish successful categories as they arrive so a slow or failing request cannot hold back other places
- give the app delegate explicit startup and shutdown ownership, reuse the existing location stream, and keep popover reopening independent of fetching
- use one core graphics image pass inside canvas after repeated swiftui symbol and image draws crashed the gpu encoder at 10,000 points
- add isolated macos swift testing coverage and deterministic dense map previews
- rationale: avoid per-place annotation views and identity churn while preserving the user's choice to show all places without clustering or thinning
- version bump: 6.3.6 (143) to 6.4.0 (144), minor for restored configurable poi functionality


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

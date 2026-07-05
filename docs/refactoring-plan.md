# Package Refactoring Plan

Refactor the app into local Swift packages named `doom-kit-core`, `doom-kit-tools`, `doom-kit-providers`, `doom-kit-ui`, and a meta-package named `doom-kit`. `doom-kit-core` owns shared domain types, reusable process-control scheduling, and package-level contracts. To keep `doom-kit-core` independent from `doom-kit-tools`, core uses a simple value/closure-based dependency injection design for network readiness and tracing. Location input is push-driven: app/tools composition observes concrete location updates and calls `ProcessManager.updateLocation(_:)`. This avoids importing concrete tools and avoids adding infrastructure protocols. `doom-kit-ui` initially contains only selected presenter state, not SwiftUI views. All packages (`doom-kit-core`, `doom-kit-tools`, `doom-kit-providers`, `doom-kit-ui`, and `doom-kit`) must support macOS 15+ and iOS 26+ without source changes.

## Steps

1. Update project instructions before implementation. `AGENTS.md` must record the five-package layout, `doom-kit-tools`, reusable process control in `doom-kit-core`, `ProcessRefreshable` renamed to `ProcessRefreshProtocol`, the shared controller/transformer contracts, the closure/value-based DI rule for core dependencies, the rule that `doom-kit-ui` contains selected presenter state only, and the platform rule: all packages support macOS 15+ and iOS 26+ without source changes.
2. Create local Swift package skeletons. Add `Packages/doom-kit-core`, `Packages/doom-kit-tools`, `Packages/doom-kit-providers`, `Packages/doom-kit-ui`, and `Packages/doom-kit` with minimal manifests and placeholder source files. Use dashed folder/package names, but expose PascalCase Swift products/modules: `DoomKitCore`, `DoomKitTools`, `DoomKitProviders`, `DoomKitUI`, and `DoomKit`. Set package platform declarations for all packages to macOS 15+ and iOS 26+. Dependencies: `doom-kit-core` has no package dependencies; `doom-kit-tools` depends on `doom-kit-core`; `doom-kit-providers` depends on `doom-kit-core` and `doom-kit-tools`; `doom-kit-ui` depends on `doom-kit-core`; `doom-kit` depends on all four products. Validate each skeleton with `swift build` and later with platform-specific builds.
3. Move core domain types into `doom-kit-core`. Move `Location`, `ProcessSensor`, `ProcessValue`, `ProcessSelector`, `ProcessQuality`, `ProcessPresentationSnapshot`, `ProcessMetadataValue`, `Hazard`, `PointOfInterest`, and `Units/*`. Keep `Location` domain-pure in core with latitude/longitude only; move `CLLocationCoordinate2D` conversion to `doom-kit-tools` or app-local extensions so `doom-kit-core` does not import `CoreLocation`. Replace current `[String: Any]?` metadata on `ProcessSensor` and `ProcessValue` with typed metadata dictionaries such as `[String: ProcessMetadataValue]`. `ProcessMetadataValue` should be a small JSON-like `Sendable` enum with cases for string, double, int, bool, array, dictionary, and null. Make needed APIs `public`. Consider making core value types `Sendable` where they cross async boundaries after metadata is typed, especially `Location`, `Hazard`, `PointOfInterest`, `ProcessSensor`, `ProcessValue`, and `ProcessPresentationSnapshot`.
4. Define core package contracts. Add/rename protocols in `doom-kit-core`: `ProcessControllerProtocol`, `ProcessTransformerProtocol`, and `ProcessRefreshProtocol`. `ProcessControllerProtocol` and `ProcessTransformerProtocol` are the shared data-layer contracts. `ProcessTransformerProtocol` should be value-returning: `render(sensor:) throws -> ProcessPresentationSnapshot`, where the snapshot contains rendered `measurements`, `current`, `faceplate`, `range`, `trend`, and any typed presentation metadata needed by app-local presenters. Do not add `ProcessServiceProtocol`; current services have provider-specific endpoint shapes and remain concrete implementation details inside `doom-kit-providers`. `ProcessRefreshProtocol` is a convenience adapter protocol replacing `ProcessRefreshable`; preserve the current async refresh seam as `refreshData(location: Location) async` unless implementation discovers a better name/signature. `ProcessManager` should not store protocol-typed presenter objects directly; registration APIs can adapt `ProcessRefreshProtocol` conformers into `ProcessSubscription` values that contain an id, timing state, and async refresh closure.
5. Design core dependency injection as values/closures, not infrastructure protocols. Add a small core dependency type, tentatively `ProcessRuntimeDependencies`, with default no-op behavior. It should contain only standard-library/Foundation-compatible closures/value types: `waitUntilReady() async` for network readiness and `ProcessLogger` closures for debug/info/warning/error. Use push-driven location input through `ProcessManager.updateLocation(_:)` rather than putting a location provider/stream into core dependencies. Do not add `NetworkClient`, `LocationProviding`, `ReverseGeocoding`, `TracingProtocol`, or similar protocols.
6. Define a core logger value type. Add a lightweight `ProcessLogger` or similarly named struct in `doom-kit-core` whose default implementation is no-op and whose live implementation is supplied by the app/tools adapter. It should be closure-backed, not protocol-backed. Core code may call this logger without knowing about `Trace`.
7. Define the location flow for core. Keep `ProcessManager` push-driven for simplicity: tools/app code observes concrete `LocationManager` and calls `ProcessManager.updateLocation(_:)`. Do not put a location provider, delegate, or `AsyncStream<Location>` into core dependencies for the initial refactor. Do not export `LocationManagerDelegate` from tools.
8. Define the network readiness flow for core. `ProcessManager` should not import or start `NetworkManager`. Instead, it receives a `waitUntilReady` async closure in `ProcessRuntimeDependencies`. The app/tools adapter can implement that closure by calling `NetworkManager.shared.startMonitoring()` and waiting for readiness. Tests can inject an immediate no-op or controlled async gate.
9. Rename or bridge current protocols before moving files. Rename current app-local `ProcessController` to `ProcessControllerProtocol` and current `ProcessRefreshable` to `ProcessRefreshProtocol`. Keep temporary typealiases only if needed for incremental migration, and remove them during final audit.
10. Refactor `ProcessManager` for core reuse before moving it. Make `ProcessManager` an `actor` that owns subscription state, current `Location`, and an async scheduling loop. Remove direct ownership of `LocationManager`, `NetworkManager`, `LocationManagerDelegate`, `Timer`, `DispatchQueue`, `Task.detached`, and `trace`. Fix the current removal logic during this refactor: `remove(subscriber:)` must remove subscriptions by the subscriber/registration id, not the manager's own id. It should receive `ProcessRuntimeDependencies` through initialization or explicit configuration. Prefer an instance-based manager for tests and package reuse; the app may still expose a shared instance at the composition root if convenient.
11. Move process-control types into `doom-kit-core`. Move the refactored `ProcessManager`, `ProcessSubscription`, `ProcessRefreshProtocol`, `ProcessRuntimeDependencies`, and `ProcessLogger` into core. Evolve `ProcessSubscription` into the actor's registration value: `id`, timeout/remaining timing state, and an async refresh closure. The actor stores `ProcessSubscription` values keyed by id rather than storing presenter objects or `any ProcessRefreshProtocol` references. Keep process control independent from `doom-kit-tools`, SwiftUI, AppKit, and provider packages. Validate `doom-kit-core` with tests for subscription minimum timeout, pending/reset behavior, add/remove subscribers, refresh triggering, injected network gate behavior, pushed location updates via `updateLocation(_:)`, and injected logging calls if meaningful.
12. Refactor the transformer base-class pattern explicitly. Keep `ProcessTransformerProtocol` and `ProcessPresentationSnapshot` in `doom-kit-core`, but move the concrete/default `ProcessTransformer` implementation to `doom-kit-providers` as a provider-side default implementation. Replace the current stateful mutation pattern with a value-returning API: provider transformers render a `ProcessSensor` into a `ProcessPresentationSnapshot` instead of storing the last rendered `measurements`, `current`, `faceplate`, `range`, and `trend` on the transformer object. This keeps trend icon defaults and faceplate formatting implementation out of core while still allowing app-local presenters to depend on the protocol.
13. Move concrete infrastructure into `doom-kit-tools`. Move `NetworkManager`, `NetworkError`, `Trace`, the global `trace` instance, reverse geocoding helpers, concrete `LocationManager` implementation, non-empty/useful `URLSession` helpers, and generic helper utilities with no process-control dependency. Candidate tools: `HaversineDistance.swift`, `OSMUtilities.swift`, `PolygonProximityCalculator.swift`, and `MathematicalSymbols.swift` if treated as a generic formatting helper. Keep tools code source-compatible with macOS 15+ and iOS 26+ by using shared Apple frameworks (`Foundation`, `CoreLocation`, `Network`) and conditional compilation only where platform APIs genuinely differ.
14. Add tool-to-core adapters in the app composition layer, not core and not the initial `doom-kit` facade. The app wires `doom-kit-tools` to `doom-kit-core` by creating `ProcessRuntimeDependencies`: `Trace` backs `ProcessLogger`, `NetworkManager` backs `waitUntilReady`, and concrete `LocationManager` updates are forwarded to `ProcessManager.updateLocation(_:)`. Move adapters into the meta-package only later if multiple apps need the same composition.
15. Remove or avoid custom infrastructure protocols during tools extraction. The current `LocationManagerDelegate` should not become a public tools protocol. Prefer callbacks for the initial refactor so the app can forward updates to `ProcessManager.updateLocation(_:)`. If a delegate remains temporarily, keep it internal to tools and remove it before final audit.
16. Keep trending/forecasting out of `doom-kit-tools`. Do not move `MovingAverage.swift`, `ExponentialMovingAverage.swift`, `GaussianSmoothing.swift`, or `ARIMA.swift` into tools. Current usages are provider/controller/forecast-adjacent, so move them with provider/controller logic or into a later dedicated analytics package only if their scope becomes broader and non-trending.
17. Move provider code into `doom-kit-providers`. Move `Services/*`, `Controllers/*`, `Transformers/*`, and provider-side forecasting/trending helpers used by controllers. Providers may import `DoomKitCore` and `DoomKitTools`, and may use WeatherKit, CoreLocation, networking, geocoding, and tracing directly. Keep provider code source-compatible with macOS 15+ and iOS 26+; isolate or conditionally compile APIs that are unavailable on one platform. Concrete controllers conform to `ProcessControllerProtocol`; concrete transformers conform to `ProcessTransformerProtocol`. Do not add domain-specific provider protocols.
18. Decouple process data presenters from concrete providers, but keep them app-local for the initial package refactor. `WeatherPresenter`, `ForecastPresenter`, `CovidPresenter`, `LevelPresenter`, `RadiationPresenter`, `ParticlePresenter`, `SurveyPresenter`, and `ProcessPresenter` currently instantiate concrete controllers/transformers and use app policy such as `UserDefaults`, `ProcessManager.shared`, `MapPresenter.shared`, and `trace`. Update these presenters to consume `ProcessPresentationSnapshot` values returned by transformers instead of reading mutable transformer state. They may be improved with dependency injection, but they are not initial `doom-kit-ui` migration targets.
19. Update process data presenters to use core process control without self-owning app policy where practical. Only data-fetching presenters should conform to `ProcessRefreshProtocol`; display-only presenters remain passive. Prefer app composition/root registration with `ProcessManager`, passing refresh intervals from `UserDefaults` or app settings. If self-registration remains temporarily, it must use an injected/core `ProcessManager` instance, not app globals.
20. Handle settings refresh actions explicitly. `SettingsView` currently calls `ProcessManager.shared.refreshSubscription(...)` and uses `LaunchAtLogin`, so it remains app-coupled and should stay app-local. If reusable settings presentation state is needed later, extract presenter/state types only; do not move the SwiftUI view into `doom-kit-ui`.
21. Handle location-driven presenters explicitly. `HazardPresenter` and `PointOfInterestPresenter` are the initial `doom-kit-ui` migration targets. They currently instantiate `LocationManager`, conform to `LocationManagerDelegate`, instantiate concrete provider controllers, and expose SwiftUI `Binding` helpers. Before moving them, inject location updates and provider fetch closures from the app/tools/provider composition layer; do not make UI depend on a public `LocationManagerDelegate` protocol or on `doom-kit-providers`.
22. Move selected reusable presentation state into `doom-kit-ui`. Move only `HazardPresenter` and `PointOfInterestPresenter` after they have been decoupled from concrete providers, location manager ownership, SwiftUI `Binding`, and app policy. Do not move SwiftUI views, SwiftUI view extensions, `ProcessPresenter`, process data presenters, `SettingsPresenter`, `ColorPresenter`, or `MapPresenter` into `doom-kit-ui` during this refactor. `doom-kit-ui` should depend on `doom-kit-core`, `Observation`, and `Foundation`; avoid `SwiftUI`, `MapKit`, `AppKit`, `doom-kit-tools`, and `doom-kit-providers`.
23. Keep app-specific composition in the app target. Keep `DashboardOfDoomApp.swift`, `AppDelegate`, entitlements, assets, menu bar setup, launch/login integration, permission policy, package wiring, network-startup policy, location permission/lifecycle policy, and likely top-level `ContentView.swift`. The app owns connecting concrete tools to core runtime dependencies.
24. Introduce the `doom-kit` meta-package facade. Make it depend on and expose `doom-kit-core`, `doom-kit-tools`, `doom-kit-providers`, and `doom-kit-ui`. Start minimal. Add composition factories only if dependency wiring becomes repetitive, especially presenter factories that combine provider controllers/transformers with UI presenters and runtime dependency construction.
25. Wire packages into the Xcode app target. Add local package dependencies, remove moved source files from the app target, and update imports. Validate with a clean app build and manual smoke test for weather, forecast, COVID, water level, radiation, particles, surveys, map, hazards, settings, location updates, geocoding, tracing, subscriptions, refresh intervals, and network monitoring.
26. Bump the app version according to the repository semantic-versioning rules after code changes. Include the version update in the same final change set as the refactor.
27. Add and expand package tests. Test pure models/units/selectors, DI defaults, injected logger, injected network gate, pushed location flow, and process-control scheduling in `doom-kit-core`; core tests must remain independent from `doom-kit-tools` and should use closure mocks/fakes only. Test concrete infrastructure and deterministic helpers in `doom-kit-tools`; transformers, endpoint-shape logic, fixture parsing, and provider forecasting helpers in `doom-kit-providers`; presenter state and formatting behavior in `doom-kit-ui`. Avoid live-network tests.
28. Final boundary audit. Confirm `doom-kit-core` has no dependency on tools, providers, UI, SwiftUI, AppKit, CoreLocation, `NetworkManager`, `LocationManager`, or `Trace`. Confirm core DI uses value/closure types rather than new infrastructure protocols. Confirm closure dependencies avoid retain cycles, especially if app-owned closures capture presenters, `ProcessManager`, `NetworkManager`, `LocationManager`, or `Trace`. Confirm `ProcessManager` actor state stores subscription registration values, not presenter objects. Confirm `doom-kit-tools` has no public infrastructure protocols such as `NetworkClient`, `LocationProviding`, `ReverseGeocoding`, `TracingProtocol`, or `LocationManagerDelegate`. Run an explicit search for stale `ProcessRefreshable` references; final source should use `ProcessRefreshProtocol` only, except possibly a temporary typealias that must be removed before completion.

## Relevant files

- `AGENTS.md` — update with five-package architecture, core process-control placement, `ProcessRefreshProtocol` rename, and core DI rule.
- `DashboardOfDoom/ProcessSensor.swift` — move to `doom-kit-core`; it is currently app-root source, not under `Models/`.
- `DashboardOfDoom/Models/Location.swift` — move latitude/longitude value type to `doom-kit-core`, but move `coordinate`/`CLLocationCoordinate2D` conversion to tools or app-local extensions.
- `DashboardOfDoom/ProcessMetadataValue.swift` — new core typed metadata enum replacing `[String: Any]?` metadata.
- `DashboardOfDoom/ProcessValue.swift` — move to `doom-kit-core` and replace `customData` with typed metadata before considering `Sendable`.
- `DashboardOfDoom/Models/Hazard.swift` — move to `doom-kit-core` so `doom-kit-ui` can expose hazard presenter state without importing providers.
- `DashboardOfDoom/Models/PointOfInterest.swift` — move to `doom-kit-core` so `doom-kit-ui` can expose point-of-interest presenter state without importing providers.
- `DashboardOfDoom/ProcessController.swift` — rename/replace current seam with `ProcessControllerProtocol`.
- `DashboardOfDoom/ProcessPresentationSnapshot.swift` — new core value type containing rendered process presentation state.
- `DashboardOfDoom/ProcessRefreshable.swift` — rename to `ProcessRefreshProtocol` and move to `doom-kit-core`.
- `DashboardOfDoom/ProcessManager.swift` — refactor out concrete dependencies, inject runtime dependencies, then move reusable subscription management to `doom-kit-core`.
- `DashboardOfDoom/ProcessSubscription.swift` — move to `doom-kit-core` and evolve into the actor's closure-backed registration value.
- `DashboardOfDoom/ProcessTransformer.swift` — split value-returning protocol from concrete/default implementation; keep trend rendering out of tools and move mutable rendering implementation to provider-side code.
- `DashboardOfDoom/NetworkManager.swift` — concrete networking infrastructure for `doom-kit-tools`; app/tools adapter supplies core network readiness closure.
- `DashboardOfDoom/LocationManager.swift` — concrete location/geocoding infrastructure for `doom-kit-tools`; app/tools adapter forwards updates to core.
- `DashboardOfDoom/Utilities/Trace.swift` — tracing infrastructure for `doom-kit-tools`; app/tools adapter maps it to core `ProcessLogger`.
- `DashboardOfDoom/Extensions/URLSession.swift` — currently only comments; move only if useful helpers are restored/added.
- `DashboardOfDoom/Utilities/HaversineDistance.swift` — generic geospatial helper candidate for `doom-kit-tools`.
- `DashboardOfDoom/Utilities/OSMUtilities.swift` — generic geospatial helper candidate for `doom-kit-tools`.
- `DashboardOfDoom/Utilities/PolygonProximityCalculator.swift` — generic geospatial helper candidate for `doom-kit-tools` after cleanup.
- `DashboardOfDoom/Utilities/MathematicalSymbols.swift` — formatting-symbol helper; likely `doom-kit-tools` if treated as generic, otherwise provider transformer support.
- `DashboardOfDoom/Utilities/MovingAverage.swift` — provider/controller transformation helper; do not move to tools.
- `DashboardOfDoom/Utilities/ExponentialMovingAverage.swift` — provider/controller transformation helper; do not move to tools.
- `DashboardOfDoom/Utilities/GaussianSmoothing.swift` — provider/controller transformation helper; do not move to tools.
- `DashboardOfDoom/Utilities/ARIMA.swift` — forecasting helper used by controllers; move with providers, not tools.
- `DashboardOfDoom/Services/*.swift` — concrete service layer for `doom-kit-providers`.
- `DashboardOfDoom/Controllers/*.swift` — concrete controller layer for `doom-kit-providers`.
- `DashboardOfDoom/Transformers/*.swift` — concrete transformer layer for `doom-kit-providers`.
- `DashboardOfDoom/Presenters/HazardPresenter.swift` — move to `doom-kit-ui` only after injecting location updates and hazard fetch closures, and removing SwiftUI `Binding` helpers.
- `DashboardOfDoom/Presenters/PointOfInterestPresenter.swift` — move to `doom-kit-ui` only after injecting location updates and point-of-interest fetch closures, and removing SwiftUI `Binding` helpers.
- `DashboardOfDoom/Presenters/*.swift` — keep other presenters app-local for the initial package refactor, including process data presenters, settings, colors, and map state.
- `DashboardOfDoom/Views/SettingsView.swift` — currently app-coupled through `LaunchAtLogin` and refresh actions; keep the SwiftUI view app-local.

## Verification

1. After instruction update, confirm `AGENTS.md` mentions `doom-kit-tools`, five packages, core process-control reuse, `ProcessRefreshProtocol`, closure/value-based DI, selected presenter-state-only `doom-kit-ui`, typed process metadata, and the macOS 15+/iOS 26+ rule for all packages.
2. After package skeleton creation, run `swift build` in each package directory, then validate all package manifests declare macOS 15+ and iOS 26+.
3. After core extraction, run `swift build` and `swift test` in `doom-kit-core`, then build the app target. Verify `ProcessSensor`, `ProcessValue`, and `ProcessPresentationSnapshot` use typed metadata rather than `[String: Any]?`.
4. After introducing core DI, test default no-op dependencies, injected logger closure calls, injected network readiness gate sequencing, and pushed location updates without importing tools.
5. After moving/refactoring `ProcessManager`, test actor-isolated subscription add/remove, remove-by-registration-id correctness, pending/reset, refresh triggering, interval minimums, scheduling-loop cancellation, and location-update-triggered refresh behavior in `doom-kit-core` without `NetworkManager`, `LocationManager`, `Timer`, `DispatchQueue`, `Task.detached`, or `Trace`.
6. After tools extraction, run `swift build` and `swift test` in `doom-kit-tools`; manually verify network monitoring, location updates, tracing, and reverse geocoding through the app after wiring.
7. After provider extraction, run `swift build` and `swift test` in `doom-kit-providers`, then run a clean app build.
8. Before UI extraction, verify process data presenters consume `ProcessPresentationSnapshot` values and no longer rely on mutable transformer state. Also verify `HazardPresenter` and `PointOfInterestPresenter` no longer instantiate concrete provider controllers, own `LocationManager`, conform to `LocationManagerDelegate`, expose SwiftUI `Binding` helpers, or import SwiftUI/MapKit/AppKit/provider modules.
9. After UI extraction, run `swift build` and `swift test` in `doom-kit-ui`, then manually inspect hazard and point-of-interest presenter behavior in the running app.
10. After adding `doom-kit`, run `swift build` in the meta-package and verify the app can resolve local package dependencies.
11. Cross-platform audit for all packages: verify `doom-kit-core`, `doom-kit-tools`, `doom-kit-providers`, `doom-kit-ui`, and `doom-kit` build for macOS 15+ and iOS 26+ without source changes; inspect imports for macOS-only frameworks outside app code.
12. Final dependency audit: `doom-kit-core` must not import SwiftUI, AppKit, CoreLocation, provider/tool modules, `NetworkManager`, `LocationManager`, or `Trace`; core DI must not introduce infrastructure protocols; `doom-kit-tools` must not import providers/UI/process-control beyond core types; `doom-kit-ui` must not import providers and must not contain SwiftUI views. Audit `doom-kit-ui` imports so presenter-only code avoids AppKit and avoids SwiftUI where `Observation`/`Foundation` are sufficient.
13. Verify the app version was bumped according to the semantic-versioning rules and included with the refactor change set.

## Decisions

- Meta-package name is `doom-kit`.
- Package set is `doom-kit-core`, `doom-kit-tools`, `doom-kit-providers`, `doom-kit-ui`, plus meta-package `doom-kit`.
- Swift product/module names are `DoomKitCore`, `DoomKitTools`, `DoomKitProviders`, `DoomKitUI`, and `DoomKit`.
- `doom-kit-ui` initially contains only selected reusable presenter state: `HazardPresenter` and `PointOfInterestPresenter` after dependency cleanup. SwiftUI views, process data presenters, settings, colors, and map state remain app-local.
- All packages (`doom-kit-core`, `doom-kit-tools`, `doom-kit-providers`, `doom-kit-ui`, and `doom-kit`) must support macOS 15+ and iOS 26+ without source changes.
- Core owns domain types, shared controller/transformer contracts, reusable process-control types, and closure/value-based runtime dependency definitions.
- `Location` in `doom-kit-core` remains a domain value only; CoreLocation coordinate conversion belongs in tools or app-local extensions.
- `Hazard` and `PointOfInterest` are core domain models because `doom-kit-ui` exposes presenter state containing them.
- Shared data-layer protocols are `ProcessControllerProtocol` and `ProcessTransformerProtocol`; there is no `ProcessServiceProtocol` in the initial refactor.
- `ProcessTransformerProtocol` returns `ProcessPresentationSnapshot` values; transformers should not expose mutable last-rendered state as their public contract.
- Core process metadata uses a JSON-like `ProcessMetadataValue` representation instead of `[String: Any]?` so domain and presentation values can become `Sendable` where feasible.
- `ProcessRefreshable` is renamed to `ProcessRefreshProtocol` and moved to `doom-kit-core` as a convenience adapter; `ProcessManager` stores closure-backed `ProcessSubscription` values, not protocol objects.
- `ProcessManager` is an actor, and its actor state stores closure-backed `ProcessSubscription` registration values rather than presenter objects.
- Core dependency injection should use structs and closures such as `ProcessRuntimeDependencies` and `ProcessLogger`, not infrastructure protocols.
- Core location input is push-driven through `ProcessManager.updateLocation(_:)`; no location stream/provider belongs in initial core DI.
- Tool-to-core adapters live in the app composition layer initially, not in core and not in the initial meta-package facade.
- `ProcessManager` must not directly depend on `NetworkManager`, `LocationManager`, `LocationManagerDelegate`, or `Trace`; those are connected by injected closures/adapters.
- Networking, geocoding, location, tracing, URLSession helpers, and generic non-process-control helpers are concrete tools.
- `LocationManagerDelegate` should not become a public tools protocol; prefer callbacks or keep temporary migration code internal.
- Domain-specific provider protocols such as `WeatherProviding` or `RadiationProviding` are out of scope.
- Controllers remain the orchestration layer for multi-endpoint providers and return normalized `[ProcessSensor]` values.
- Trending/forecasting helpers do not belong in `doom-kit-tools`.

## Further considerations

1. Keep `ProcessRuntimeDependencies` small. If a closure is not needed by core, do not add it preemptively.
2. Prefer constructor injection for `ProcessManager` in tests and reusable contexts. The app may still expose a shared instance for convenience, but the shared instance should be configured at the composition root.
3. The app remains responsible for permission policy, network startup policy, and connecting concrete tools (`LocationManager`, `NetworkManager`, `Trace`) to core process control (`ProcessManager`).

## Completion Status

Completed on 2026-07-05. Remaining refactor work from steps 25–28 is done.

| Verification | Status | Notes |
|---|---|---|
| 1. AGENTS.md five-package layout | Done | Documented in AGENTS.md |
| 2. Package skeletons + platform declarations | Done | macOS 15+, iOS 26+ in all manifests |
| 3. Core extraction + typed metadata | Done | `swift build` / `swift test` in `doom-kit-core` |
| 4. Core DI tests | Done | Default deps, injected logger, network gate |
| 5. ProcessManager actor tests | Done | Add/remove, refresh, location push, stop/start |
| 6. Tools extraction + tests | Done | Geospatial helper tests; `LocationManagerDelegate` removed |
| 7. Provider extraction + tests | Done | Transformer and moving-average tests |
| 8. Presenter snapshot consumption | Done | App presenters use `ProcessPresentationSnapshot` |
| 9. UI package tests | Done | Hazard/POI presenter tests with mock closures |
| 10. Meta-package wiring | Done | App links local `Packages/doom-kit` |
| 11. Cross-platform builds | Done | All packages build on macOS and iOS 26 simulator |
| 12. Final dependency audit | Done | Core/tools/ui boundaries verified; no `ProcessRefreshable` in source |
| 13. Version bump | Done | 7.0.1 (139) |

Deferred (optional follow-up): presenter controller/transformer injection at app root; centralised subscription registration outside presenter `init()`.

## Phase 2 — Process Presenters in `doom-kit-ui`

Completed on 2026-07-05.

| Step | Status | Notes |
|---|---|---|
| Duplicate app source cleanup | Done | Removed shadowed Controllers/Services/Transformers/Units |
| `ProcessPresenter` in `doom-kit-ui` | Done | Public `apply(sensor:snapshot:)` helper |
| `ProcessDataPresenter` + named types | Done | Closure injection for fetch/render/log/map |
| Centralised registration | Done | `AppProcessControl.registerProcessPresenters` |
| `AppFactories` expansion | Done | All seven domains + hazard/POI |
| Survey gradient extension | Done | App-local `SurveyPresenter+Gradient.swift` |
| Tests + verification | Done | 6 UI package tests; macOS app build; iOS 26 simulator build |
| Version bump | Done | 7.0.2 (140) |

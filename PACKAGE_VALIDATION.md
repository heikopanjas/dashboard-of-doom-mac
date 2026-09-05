# Package extraction validation

## Map collision score precision: 6.3.6 (143)

Validated September 5, 2026 with Apple Swift 6.2.4 and Xcode 26.3.

- Reproduced failures before the fix: unobstructed fractional-coordinate labels
  moved away from their dots, including an unnecessary connector; obsolete offsets
  also survived after surrounding labels were removed.
- Tools Debug and Release: all 22 tests passed after the fix. Genuine clipping,
  crowded layouts, bounded fallback, and fractional placement stability still pass.
- Clipping now sums nonnegative outside strips. Contained rectangles score exactly
  zero; overlap edge noise at or below 0.0000001 point is ignored before scoring.
  The strict arrangement comparator is unchanged.
- Signed Debug and Release builds and deep/strict signature verification passed.
- Formatting and whitespace checks passed. The corrected Debug app was launched.
  The live map displayed all six enabled labels attached to their dots, including
  COVID, with no connector lines needed in that layout. The app remains running.
  No preferences, signing settings, entitlements, or dependency pins changed.
- Other package suites and app lifecycle tests were not repeated for this pure
  solver correction. Earlier validation remains recorded below. No commit made.


## Direct map label attachment: 6.3.5 (142)

Validated September 5, 2026 with Apple Swift 6.2.4 and Xcode 26.3.

- Tools Debug and Release: 19 tests passed in each configuration.
- Signed Debug and Release builds and deep/strict signature verification: passed.
- Regression cases assert exact above-right attachment and removal of obsolete
  connectors after other labels disappear or projected locations spread apart.
- The separated-location preview was rendered using the real app views in a
  temporary harness: all six labels met their dots without connector lines.
- Existing collision, marker, edge, dense-cluster, bounded-search, and fractional
  projection tests still pass. Attached labels intentionally meet their source
  marker; clearance remains enforced around unrelated markers.
- Geometry caching is unchanged. Placement scoring now prioritizes connector
  count and normal anchors ahead of retaining previous positions.
- Formatting and whitespace checks passed. No preferences were changed. Other
  package suites and the unchanged app lifecycle were not rerun for this solver
  correction; their preceding validation is recorded below. No commit was made.


## Map annotation layout: 6.3.4 (141)

Validated September 5, 2026 using Apple Swift 6.2.4 and Xcode 26.3 (17C529) on
macOS. The project spec's existing Xcode compatibility setting is unchanged.

| Check | Result |
| --- | --- |
| Location Debug | 6 tests passed |
| Network Debug | 12 tests passed |
| Process Debug and Release | 16 tests passed in each configuration |
| Tools Debug and Release | 17 tests passed in each configuration |
| Services Debug and Release | 2 tests passed in each configuration |
| Signed Debug and Release app builds | Passed via build.sh, including XcodeGen regeneration |
| Debug and Release deep/strict codesign verification | Passed |
| Release bundle version | 6.3.4, build 141 |
| Swift formatting for new files and whitespace check | Passed |
| Dependency lockfile, signing configuration, entitlements | Unchanged |

Ordinary-import geometry tests cover separated and coincident points (two through
six), dense clusters, viewport edges, mixed label sizes, marker-only obstacles,
marker clearance, exact connector boundaries, grid fallback for offscreen sources,
invalid projections, undersized viewports, deterministic search bounds, and
retention after location, visibility, viewport, size, and fractional-coordinate
changes. The bounded beam is not a proof of globally optimal placement.

A temporary SwiftUI harness compiled the real app views with the deterministic
preview fixtures and inactive presenters. Six coincident labels and a narrow dense
cluster rendered with connectors. Resizing recomputed their positions; native dots
stayed at the projected sources. The undersized fixture retained all six
measurements in its accessibility tree. The accessibility tree contained each fixture
measurement once and no connector announcements. This was an accessibility-tree
inspection, not a full spoken VoiceOver audit. Harness artifacts are temporary and
are not production startup options.

Live Debug checks verified startup, Weather label off/on with the location dot
retained, COVID visibility off/on, and restoration of both exercised preferences.
The checks exposed and corrected transient MapReader registration gaps: geometry
changes now use a cancellable view task with at most eight 16 ms projection attempts,
and camera changes still update directly. Geometry and placement publish together;
text-only refreshes do not start a layout task. Projection is never performed in
body rendering. The corrected fixture emitted no AttributeGraph cycle warnings.

Popover reopening retained all five enabled labels. A normal five-minute Weather
refresh advanced the timestamp from 22:08 to 22:13 and the temperature from 14.9 °C
to 14.8 °C, with all enabled labels still present. Normal app termination completed;
no Dashboard of Doom process remained. The temporary fixture process was stopped.
Weather and COVID were restored to their original enabled values; refresh intervals
and all other preferences were untouched.

The unchanged build script's mock tests were not repeated. Builds retained the
existing AppIntents metadata extraction warning. iOS presentation is unchanged and
unvalidated. No commit was created.

## Units, tools, and services: 6.3.3 (140)

Validated September 5, 2026 using Apple Swift 6.2.4 and Xcode 26.2 on macOS.

| Check | Result |
| --- | --- |
| DoomKitLocation Debug | 6 tests passed |
| DoomKitNetwork Debug | 12 tests passed |
| DoomKitProcess Debug and Release | 16 tests passed in each |
| DoomKitTools Debug and Release | 7 test functions, 14 cases passed in each |
| DoomKitServices Debug and Release | 2 test functions, 100 cases passed in each |
| Signed Debug and Release via build.sh | Passed, including XcodeGen regeneration |
| Strict deep signature verification, both builds | Passed |
| Release bundle version | 6.3.3, build 140 |
| Local dependency graph | Acyclic; Tools depends only on Location |
| Original app Units, Utilities, Services files | All 23 removed from the app source tree |
| Dependency pin, signing settings, entitlements | Preserved |
| Whitespace check | Passed |

Ordinary-import unit tests cover all exported symbols, conversion coefficients,
base units, representative conversions, and ProcessValue use. Tools tests compare
smoothing and deterministic forecasts with outputs captured by running the original
functions before extraction. Coverage includes empty input, shortened and oversized
windows, mixed compatible units, Gaussian edge normalization and clamping,
invalid Gaussian parameters, ARIMA interval/data validation, geometry, symbol
mappings, and 100 concurrent log writes to a temporary file. Logging retains the
original lexical level filtering. No new unchecked Sendable conformance was added.

Service fixtures were captured by executing the original 25 methods against a
recording fake. All methods preserve exact requests and successful bytes, map
server errors and transport cancellation to nil, and honor cancellation before
requests. Transport, monitoring, and sleep are injected; package tests perform no
live networking or permission requests. Particle fixtures preserve the original
from-date hour for both time parameters and local calendar/formatter defaults.

The app's two Gaussian callers zip original values with smoothed measurements,
preserving order, unit, timestamp, quality, and arbitrary metadata. Construction
continues to create fresh UUIDs. Controllers, parsing, presenters, transformers,
Date extensions, and WeatherKit remain in the app.

The signed Debug popover displayed current measurements. Opening Settings and
turning Use Nearest Sensor on changed the displayed water level from 2.73 m to
4.03 m. The original off setting was restored and the measurement returned to
2.73 m. Refresh intervals were not changed. With the transient popover hidden,
the normal periodic timestamp advanced from 21:36 to 21:41; reopening it showed
the updated measurements. Debug was quit through its own Quit button.
The signed Release executable also launched, displayed measurements with a
21:41 timestamp, opened Settings, and quit through its own Quit button. Process
inspection confirmed shutdown of both builds. These checks cover startup,
measurements, popover, settings refresh, periodic refresh, and clean shutdown;
they do not establish visual correctness of every panel or permission path.

iOS remains unvalidated. Both app builds emitted only the existing skipped
AppIntents metadata extraction warning. build.sh was unchanged, so its Python
mock suite and shell checks were not repeated for this extraction. No commit
was created.

## Process module expansion: 6.3.2 (139)

Validated September 5, 2026 with Apple Swift 6.2.4 and Xcode 26.2.

| Check | Result |
| --- | --- |
| DoomKitLocation Debug | 6 tests passed |
| DoomKitNetwork Debug | 12 tests passed |
| DoomKitProcess Debug and Release | 15 tests passed in each configuration |
| Signed Debug and Release via build.sh | Passed, including XcodeGen regeneration |
| Strict signature verification, both app builds | Passed |
| App Process*.swift inventory | No files remain under DashboardOfDoom |
| Dependency pins, signing and entitlements | Preserved |

Public API tests use ordinary imports and cover external presenter subclassing,
transformer overrides, protocol conformance, model construction, UUIDs, metadata,
selector mappings, geographic helpers and default transformation output.
Coordinator tests inject source interfaces and clocks to cover inactive
construction, fallback registration, first and subsequent measured locations,
settings and periodic refreshes, timeout readiness, stop/restart, cancellation,
and weak presenter/coordinator ownership. No test uses live networking or
requests location permission.

The Debug desktop smoke test displayed current measurements and opened Settings.
The nearest-water-level-sensor setting was toggled and restored to its original
value (off); refresh intervals were left unchanged. The popover timestamp
advanced from 21:06 to 21:11 across the normal periodic interval, including
while the transient popover was hidden. Debug quit through the application
termination path. The signed Release app also launched, displayed measurements
and a 21:12 timestamp, and quit cleanly. Process inspection confirmed both
executables exited. The Release bundle reports version 6.3.2, build 139.
These checks establish startup, popover presentation, periodic data flow and
shutdown; they do not validate every visual panel or interactive permission path.

SwiftUI integration retains the observable base and app-owned concrete
presenters. Immutable presenter UUID access is explicitly nonisolated to satisfy
external Identifiable conformances under Swift 6. No unchecked Sendable
conformances or metadata conversions were introduced.

iOS remains unvalidated. The builds emit the usual skipped AppIntents metadata
extraction warning because the app does not depend on AppIntents.
Build-script checks below belong to the preceding extraction; build.sh was not
changed by this refactor.

## Earlier package extraction: 6.3.1 (138)

Validated September 5, 2026 on macOS 15.8 with Apple Swift 6.2.4 and Xcode 26.2.
App version 6.3.1, build 138. Packages declare macOS 15 and iOS 26; iOS is unvalidated.

| Check | Result |
| --- | --- |
| DoomKitLocation Debug tests | 6 tests passed, including 3 movement-threshold cases |
| DoomKitNetwork Debug tests | 12 tests passed, including 2 HTTP-status cases |
| DoomKitProcess Debug tests | 7 tests passed |
| DoomKitProcess Release tests | 7 tests passed |
| Signed Debug build after each extraction phase | Passed |
| Final signed Debug build | Passed |
| Final signed Release build | Passed, arm64 and x86_64 |
| Signature verification, Debug and Release | Passed with system trust-store access |
| Build-script Python tests | 6 passed |
| `bash -n build.sh`, `shellcheck build.sh` | Passed |
| `git diff --check` | Passed |

Package tests substitute location/geocoding providers, network transport and
monitoring, and process clocks. They do not access live network services.

The signed Debug startup smoke test received a measured location, replaced the
app-owned fallback, and fetched radiation, air-quality, water-level, and COVID
data. Quit completed through the app termination path. These logs establish
startup and data flow, not visual correctness of every panel.

The Release popover displayed current measurements and Settings opened.
Four rapid changes to the nearest-water-level-sensor toggle triggered replacement
refreshes; its original value was restored (off before and after), and the popover
remained responsive. Across the normal five-minute refresh interval, the
popover's timestamp advanced from 20:46 to 20:51 without changing refresh
preferences. Reopening the transient popover showed the new data, confirming
updates continue independently of popover visibility. The Release app then
quit cleanly.

The interactive permission-prompt paths and visual offline recovery still require
desktop smoke testing. Scheduling, authorization states, offline recovery, repeated
refresh cancellation, and late completion are covered with deterministic package
tests. No preferences were changed to shorten refresh intervals.

Build validation found two Swift 6.2.4 issues resolved in this implementation:

- constructing the default async timing closure inside the network initializer
  avoided a reproducible runtime failure in readiness tests;
- Sendable scheduler registration storage permits nonisolated teardown, avoiding
  a Release optimizer crash in a generic isolated deinitializer.

The app identity, signing settings, entitlements, and LaunchAtLogin dependency
pin were preserved. Existing untracked agent/configuration files were preserved.
No commit, remote publication, iOS integration, or native live-update provider
was performed.

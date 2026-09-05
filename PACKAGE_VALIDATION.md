# Package extraction validation

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

# Project Instructions for AI Coding Agents

**Last updated:** 2026-07-05 (one primary type per file refactor)

<!-- {preamble} -->

# ⚠️ Before You Start

Run `/init-session` at the beginning of each new session, OR read this entire file before proceeding.

**DO NOT** make code changes or commits until you have done one of the above.

<!-- {mission} -->

## Mission Statement

Dashboard of Doom is a macOS menu bar application that aggregates and visualises real-time environmental monitoring data. It pulls from multiple public APIs to display weather forecasts, air quality (particle concentration), radiation levels, water levels, COVID incidence, hazard alerts, and points of interest — all in a compact, always-available menu bar interface.

## Technology Stack

- **Language:** Swift
- **Framework:** SwiftUI + AppKit (macOS menu bar app via `MenuBarExtra`)
- **Version Control:** Git
- **Package Manager:** Swift Package Manager (Xcode-managed)
- **License:** MIT
- **Minimum Target:** macOS (see Xcode project settings)

## Session Protocol

When starting a new session, read this entire file and confirm you have
understood the project instructions before proceeding. Summarize the project
purpose and key conventions briefly. Do not make changes until you have
confirmed your understanding.

<!-- {principles} -->

## Primary Instructions

- Avoid making assumptions. If you need additional context to accurately answer the user, ask the user for the missing information. Be specific about which context you need.
- Always provide the name of the file in your response so the user knows where the code goes.
- Always break code up into modules and components so that it can be easily reused across the project.
- All code you write MUST be fully optimized. ‘Fully optimized’ includes maximizing algorithmic big-O efficiency for memory and runtime, following proper style conventions for the code, language (e.g. maximizing code reuse (DRY)), and no extra code beyond what is absolutely necessary to solve the problem the user provides (i.e. no technical debt). If the code is not fully optimized, you will be fined $100.

### Working Together

This file (`AGENTS.md`) is the primary instructions file for AI coding assistants working on this project. Agent-specific instruction files (such as `.github/copilot-instructions.md`, `CLAUDE.md`) reference this document, maintaining a single source of truth.

When initializing a session or analyzing the workspace, refer to instruction files in this order:

1. `AGENTS.md` (this file - primary instructions and single source of truth)
2. Agent-specific reference file (if present - points back to AGENTS.md)

### Update Protocol (CRITICAL)

**PROACTIVELY update this file (`AGENTS.md`) as we work together.** Whenever you make a decision, choose a technology, establish a convention, or define a standard, you MUST update AGENTS.md immediately in the same response.

**Update ONLY this file (`AGENTS.md`)** when coding standards, conventions, or project decisions evolve. Do not modify agent-specific reference files unless the reference mechanism itself needs changes.

**When to update** (do this automatically, without being asked):

- Technology choices (build tools, languages, frameworks)
- Directory structure decisions
- Coding conventions and style guidelines
- Architecture decisions
- Naming conventions
- Build/test/deployment procedures

**How to update AGENTS.md:**

- Maintain the "Last updated" timestamp at the top
- Add content to the relevant section (Project Overview, Coding Standards, etc.)
- Add entries to the "Recent Updates & Decisions" log at the bottom with:
  - Date (with time if multiple updates per day)
  - Brief description
  - Reasoning for the change
- Preserve this structure: title header → timestamp → main instructions → "Recent Updates & Decisions" section

## Best Practices

### When Updating This Repository

1. **Maintain Consistency**: Keep code style consistent across the codebase
2. **Test First**: Write tests before implementing features when applicable
3. **Document Changes**: Update documentation when changing functionality
4. **Code Review**: [Describe your code review process]
5. **Date Changes**: Update the "Last updated" timestamp in this file when making changes
6. **Log Updates**: Add entries to "Recent Updates & Decisions" section below

### Development Guidelines

- Follow the layered architecture: **Controllers → Services → Transformers → Presenters → Views**
  - Package layout under `Packages/`:
    - `doom-kit-core` (`DoomKitCore`) — domain models, units, selectors, process-control scheduling, shared controller/transformer protocols, typed metadata, presentation snapshots
    - `doom-kit-tools` (`DoomKitTools`) — networking, location, tracing, geospatial helpers, CoreLocation extensions
    - `doom-kit-providers` (`DoomKitProviders`) — concrete services, controllers, transformers, forecasting/trending helpers
    - `doom-kit-ui` (`DoomKitUI`) — reusable presenter state: `ProcessPresenter`, process data presenters, `HazardPresenter`, `PointOfInterestPresenter`; no SwiftUI views
    - `doom-kit` (`DoomKit`) — meta-package re-exporting all four products
  - App target (`DashboardOfDoom/`) — SwiftUI views, app-local presenters, composition root (`Composition/`), assets, entitlements
  - `Controllers/` — orchestrate data fetching and refresh cycles (in `doom-kit-providers`)
  - `Services/` — raw API/network calls (in `doom-kit-providers`; no shared service protocol)
  - `Transformers/` — map sensors to `ProcessPresentationSnapshot` values (in `doom-kit-providers`)
  - `Presenters/` — app-local process presenters plus package UI presenters injected at composition root
  - `Models/` — domain types in `doom-kit-core`
  - `Views/` — SwiftUI views in app target only
  - `Units/` — custom `Dimension`/`Unit` subclasses in `doom-kit-core`
  - `Extensions/` — app-local SwiftUI/AppKit extensions; CoreLocation coordinate conversion lives in `doom-kit-tools`
- Each data domain owns its full vertical slice in `doom-kit-providers`; app presenters consume protocols and snapshots
- Use `@Observable` (Swift 5.9 Observation framework) for presenter state; avoid `ObservableObject`/`@Published`
- Inject presenters via SwiftUI `.environment(_:)` at the app root
- Shared data-layer protocols in `doom-kit-core`: `ProcessControllerProtocol`, `ProcessTransformerProtocol`, `ProcessRefreshProtocol` (adapter only; `ProcessManager` stores closure-backed `ProcessSubscription` values)
- No `ProcessServiceProtocol`; services remain concrete provider implementation details
- `ProcessTransformerProtocol` returns value-type `ProcessPresentationSnapshot`; transformers must not expose mutable last-rendered state
- Process metadata uses JSON-like `ProcessMetadataValue` / `ProcessMetadata` instead of `[String: Any]?`
- `ProcessManager` is an `actor`; location input is push-driven via `updateLocation(_:)`; runtime dependencies use `ProcessRuntimeDependencies` and `ProcessLogger` closures, not infrastructure protocols
- Tool-to-core adapters live in `DashboardOfDoom/Composition/` (`AppProcessControl`, `ProcessRuntimeAdapter`, `AppFactories`)
- All packages support macOS 15+ and iOS 26+ without source changes
- Package boundaries must be protocol based; concrete provider implementations are injected by the app composition root or factories, not referenced directly from UI package code

### Security & Safety

- Never include API keys, tokens, or credentials in code
- Always require explicit human confirmation before commits
- Maintain conventional commit message standards
- Keep change history transparent through commit messages
- [Add project-specific security guidelines]

### Testing

- Load the `swift-testing-pro` skill before writing or reviewing tests
- Unit tests target Transformers and pure logic in Models/Units
- Use Swift Testing framework (not XCTest) for new tests
- Test coverage: focus on Transformers and Units; UI tests are out of scope

### Documentation

- Code comments: only where intent is non-obvious; no boilerplate doc-comments
- README: update when adding new data sources or changing setup steps
- No separate changelog file; history is in Git commits and the AGENTS.md log

<!-- {languages} -->

## Swift Coding Standards

Load the `swift-coding-conventions` skill before writing, reviewing, or refactoring Swift code.
Load the `swift-build-commands` skill when building or running the project.

- **One primary type per file:** each top-level `class`, `struct`, `enum`, and `actor` gets its own `.swift` file named after the type; see the skill for narrow exceptions (nested helpers only).

<!-- {integration} -->

## Commit Protocol

- **NEVER commit automatically** — always wait for explicit user confirmation
- Stage changes, write a conventional commits message (max 50-char subject, 72-char body lines), then commit
- Load the `git-workflow` skill for the full message format, character limits, and examples before committing

## Semantic Versioning

Automatically bump the project version after every code change and include it in the same commit. Load the `semantic-versioning` skill for the full PATCH/MINOR/MAJOR decision rules.

---

<!-- {changelog} -->

## Recent Updates & Decisions

### 2026-07-05 (one primary type per file refactor)

- Split multi-type Swift files across packages and app to match `swift-coding-conventions` (one class/struct/enum/actor per file)
- Removed regressed duplicate app sources under `Controllers/`, `Services/`, `Transformers/`, and `Units/` again
- Renamed survey `Descriptor` to `SurveyPartyDescriptor`; removed unused polygon proximity demo classes
- Bumped app version to 7.0.4 (build 142)

### 2026-07-05 (one primary type per file)

- Strengthened `swift-coding-conventions` File Organization: each top-level class, struct, enum, and actor must have its own implementation file; skill version 2.1

### 2026-07-05 (duplicate cleanup + interval re-registration)

- Removed regressed duplicate app sources under `Controllers/`, `Services/`, `Transformers/`, and `Units/`
- `AppProcessControl` stores process presenter registrations and supports `reregisterProcessPresenters(forIntervalKey:)`
- `SettingsView` re-registers subscriptions when refresh interval `@AppStorage` values change
- Bumped app version to 7.0.3 (build 141)

### 2026-07-05 (Phase 2 UI presenters)

- Moved `ProcessPresenter` and seven process data presenters into `doom-kit-ui` as `ProcessDataPresenter` with injected fetch/render/log/map closures
- Named presenter types (`WeatherPresenter`, etc.) remain distinct for SwiftUI `@Environment` typing
- Centralised `UserDefaults` refresh intervals and `ProcessManager` registration in `AppProcessControl.registerProcessPresenters`
- Expanded `AppFactories` to wire provider controllers/transformers and map visibility policy
- Kept `SurveyPresenter.gradient(selector:)` as app-local SwiftUI extension in `SurveyPresenter+Gradient.swift`
- App-local after Phase 2: `MapPresenter`, `SettingsPresenter`, `ColorPresenter`, all SwiftUI views, composition layer
- Bumped app version to 7.0.2 (build 140)

### 2026-07-05 (refactor completion)

- Removed duplicate app-local `Controllers/`, `Services/`, `Transformers/`, and `Units/`; app now uses package types via `import DoomKit`
- Added Swift Testing coverage across all four packages (24 tests total: core 11, tools 6, providers 4, UI 3)
- Removed internal `LocationManagerDelegate`; location updates use `onLocationUpdate` callback only
- Completed verification checklist in `docs/refactoring-plan.md`; cross-platform builds verified (macOS + iOS 26 simulator)
- Updated README project structure and architecture sections for package layout
- Bumped app version to 7.0.1 (build 139)

### 2026-07-05 (package refactor)

- Implemented five-package layout: `doom-kit-core`, `doom-kit-tools`, `doom-kit-providers`, `doom-kit-ui`, and meta-package `doom-kit` under `Packages/`
- Swift product/module names: `DoomKitCore`, `DoomKitTools`, `DoomKitProviders`, `DoomKitUI`, `DoomKit`
- Moved domain types, units, process control, and protocols into `doom-kit-core`; `ProcessManager` is an actor with closure-backed `ProcessSubscription` registration
- Renamed `ProcessRefreshable` to `ProcessRefreshProtocol`; dropped `ProcessServiceProtocol`
- Added `ProcessPresentationSnapshot`, `ProcessMetadataValue`, and value-returning `ProcessTransformerProtocol`
- Moved infrastructure to `doom-kit-tools`; providers to `doom-kit-providers`; `HazardPresenter` and `PointOfInterestPresenter` to `doom-kit-ui`
- App composition lives in `DashboardOfDoom/Composition/`; SwiftUI views and process data presenters remain app-local
- Bumped app version to 7.0.0 (build 138)

### 2026-07-05

- Session init: filled in all template placeholders in AGENTS.md with actual project details
- Documented the layered architecture (Controllers/Services/Transformers/Presenters/Views)
- Confirmed technology stack: Swift + SwiftUI/AppKit, macOS menu bar app
- Confirmed use of Swift 5.9 `@Observable` over `ObservableObject`
- Added testing guidance: Swift Testing framework, focus on Transformers/Units
- No `.github/copilot-instructions.md` present; AGENTS.md is the sole instruction source
- Decided package refactor target: `doom-kit` meta-package containing `doom-kit-core`, `doom-kit-providers`, and `doom-kit-ui`
- Established package interface rule: cross-package dependencies use public protocols and dependency injection to keep UI independent from concrete provider implementations
- Corrected meta-package naming from `doom-kt` to `doom-kit` to match the intended package name

### 2025-10-05

- Initial AGENTS.md setup
- Established core coding standards and conventions
- Created agent-specific reference files
- Defined repository structure and governance principles

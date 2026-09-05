# Dashboard of Doom (macOS)

![Swift 5 language mode](https://img.shields.io/badge/Swift-5_language_mode-orange.svg)
![macOS 15.0+](https://img.shields.io/badge/macOS-15.0+-blue.svg)
![MIT License](https://img.shields.io/badge/License-MIT-green.svg)

**Dashboard of Doom** is a sophisticated macOS menu bar application that provides real-time environmental and public health data visualization for Germany. This comprehensive monitoring dashboard aggregates data from multiple German government and public APIs to create an interactive, location-aware environmental monitoring system.

> **Regional Focus**: This application is specifically designed for use in Germany and integrates with German federal data sources.

> **Note**: This repository contains the macOS-only version. A separate iOS repository is available with similar architecture but platform-specific implementations.

## Map annotation layout

Version 6.3.6 (build 143) separates crowded macOS map labels while keeping location
dots at their geographic coordinates. Labels retain their existing appearance and attach directly above-right of their
dots when space permits. Crowded labels use category-colored connectors, which
disappear when space opens up. Direct attachment takes priority over retaining
a previous offset. It preserves every enabled label, using the least-colliding
arrangement found when the viewport is too small. Turning off Weather hides its
label while retaining the location dot.

The map remains noninteractive and retains its existing region-fitting behavior.
`MapView` creates one category-ordered snapshot; `CollisionMapView` projects it
through `MapReader` after geometry changes and caches layout independently of label
text. A cancellable view task handles temporary map-registration gaps. `DoomKitTools.AnnotationLayout` owns the bounded screen-space search.
Deterministic crowded-layout previews live in `MapAnnotationPreview.swift`.
The separate iOS annotation presentation is unchanged and unvalidated.

## Screenshots

<div align="center">

**Main Dashboard**
![macOS Main Dashboard](images/macos-main.png)

**Weather Forecast**
![macOS Weather Forecast](images/macos-forecast.png)

**Environmental Monitoring**
![macOS Environmental Data](images/macos-environment.png)

**Particle Analysis**
![macOS Particle Data](images/macos-particles.png)

**State Election Polls**
![macOS State Election Polls](images/macos-state.png)

**Federal Election Polls**
![macOS Federal Election Polls](images/macos-federal.png)

</div>

## Features

### macOS Menu Bar Application

- **Lightweight Menu Bar Extra**: Quick access to current conditions from system tray
- **Live Temperature Display**: Real-time temperature in menu bar status item
- **Streamlined Header Bar**: Direct action buttons for settings and quit (no menu needed)
- **Adaptive Branding**: Text title in light mode, logo image in dark mode
- **Settings Window**: Comprehensive configuration for preferences and data sources
- **Dark Mode Optimized**: Native macOS appearance with pure black backgrounds
- **System Integration**: Native macOS notifications and alerts
- **Low Resource Usage**: Optimized for background operation with minimal system impact

### Data Sources & Monitoring

- **COVID-19 Tracking**: Real-time incidence rates, cases, deaths, and recovery data
- **Radiation Monitoring**: Federal radiation levels from BfS (Bundesamt für Strahlenschutz)
- **Air Quality**: PM10, PM2.5, O3, NO2 particle concentrations from UBA
- **Weather & Forecasting**: Current conditions and ARIMA-based future predictions
- **Water Levels**: Hydrological data from federal waterway stations
- **Civil Protection**: NINA hazard alerts and emergency notifications
- **Political Surveys**: Election polling data and trend analysis
- **Points of Interest**: Nearby hospitals, pharmacies, and essential services

### Advanced Capabilities

- **Automatic Data Refresh**: Intelligent subscription-based updates
- **Quality Assessment**: Built-in data validation and quality scoring
- **Trend Analysis**: Mathematical trend indicators with Unicode symbols (Ω, Γ, ρ, etc.)
- **Location Intelligence**: GPS-based data filtering and regional focus
- **Network Resilience**: Robust error handling with automatic retry mechanisms

## Architecture & Design

### Architecture Pattern

- **MVP (Model-View-Presenter)**: Optimized for menu bar applications with reactive state management
- **Environment-Based Injection**: SwiftUI environment pattern for presenter dependencies
- **Observable State**: Modern `@Observable` macro for reactive UI updates

### Core Architecture Components

```text
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Controllers   │────│    Services     │────│  External APIs  │
│  Data Fetching  │    │  HTTP/Network   │    │ German Federal  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  Transformers   │────│   Presenters    │────│     Views       │
│ Data Processing │    │ State Management│    │ SwiftUI Interfaces│
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

#### Data Flow Pipeline

1. **Controllers**: Orchestrate API communication and data parsing
2. **Services**: Handle HTTP requests to German federal APIs
3. **Transformers**: Process raw data into UI-ready formats with quality assessment
4. **Presenters**: Manage application state using `@Observable` macro
5. **Views**: SwiftUI interfaces with environment-based dependency injection

#### Key Design Patterns

- **Subscription System**: `AppProcess.shared` constructs the package coordinator that connects location/network streams to `DoomKitProcess.ProcessManager`
- **Observer Pattern**: `ProcessRefreshable` protocol for reactive components
- **Transformer Pattern**: Clean separation of data processing from presentation
- **Quality Assessment**: Built-in measurement validation and confidence scoring

## Technical Implementation

### Modern Swift Features

- **Swift 5 language mode**: Modern Swift compiler with async/await support
- **Concurrency**: Comprehensive async/await implementation
- **Observable Macro**: macOS 15+ state management with `@Observable`
- **Environment Injection**: SwiftUI environment-based dependency management
- **Sendable Conformance**: Proper thread-safety with `@unchecked Sendable` for custom types

### Data Processing Excellence

- **Real-time Transformations**: Sophisticated data normalization pipeline
- **Mathematical Analysis**: Trend calculation and statistical processing
- **Unit Standardization**: Automatic measurement unit conversion
- **Quality Metrics**: Data confidence and reliability assessment

### Network Architecture

- **Resilient Networking**: Automatic retry with exponential backoff
- **Connection Monitoring**: Network availability detection and adaptation
- **API Integration**: RESTful services with comprehensive error handling
- **Data Validation**: JSON parsing with type safety and error recovery

## Project Structure

```text
dashboard-of-doom-mac/
├── DashboardOfDoom/                  # macOS Application Source
│   ├── Controllers/                  # Data orchestration layer
│   ├── Presenters/                   # State management (MVP)
│   ├── Transformers/                 # Data processing pipeline
│   ├── Views/                        # SwiftUI user interfaces
│   ├── Models/                       # Core data structures
│   ├── Extensions/                   # Swift utility extensions
│   ├── Assets.xcassets/              # App icons and image assets
│   ├── DashboardOfDoomApp.swift      # App entry point
│   ├── ContentView.swift             # Main view with header bar and panels
│   ├── AppLocation.swift             # App-owned fallback and location lifecycle
│   └── AppProcess.swift              # Constructs and starts the package coordinator
├── doom-kit-location/               # DoomKitLocation package and tests
├── doom-kit-network/                # DoomKitNetwork package and tests
├── doom-kit-process/                # Process models, custom units, coordinator and scheduler
├── doom-kit-tools/                  # Smoothing, forecasting, geometry, symbols and logging
├── doom-kit-services/               # Seven API services with injected networking
├── project.yml                      # Authoritative XcodeGen specification
├── DashboardOfDoom.xcodeproj/        # Generated project; package lockfile tracked
├── AGENTS.md                         # AI agent instructions
├── LICENSE                           # MIT License
└── README.md                         # This documentation
```

### Specialized Components

#### Presenters (State Management)

- `WeatherPresenter` - Current weather conditions and atmospheric data
- `ForecastPresenter` - Weather predictions with ARIMA forecasting models
- `CovidPresenter` - COVID-19 epidemiological data and trends
- `LevelPresenter` - Hydrological measurements and water level monitoring
- `RadiationPresenter` - Environmental radiation monitoring and alerts
- `ParticlePresenter` - Air quality measurements (PM10, PM2.5, O3, NO2)
- `SurveyPresenter` - Political polling data and electoral trend analysis
- `HazardPresenter` - Civil protection alerts and emergency notifications
- `MapPresenter` - Shared geographic state and location management

#### Data Sources Integration

- **BfS (Bundesamt für Strahlenschutz)**: Radiation monitoring network
- **UBA (Umweltbundesamt)**: Federal environmental agency air quality data
- **Pegelonline**: Federal waterway and shipping administration data
- **NINA API**: National warning system for civil protection
- **Corona-Zahlen.org**: COVID-19 statistics aggregation service
- **OpenStreetMap**: Geographic data and points of interest
- **DAWUM**: Political polling and survey data aggregation

## Getting Started

### Prerequisites

- **macOS 15.0+** (Sequoia or later)
- **Xcode 26.2+** with Swift 6.2 and macOS SDK
- **XcodeGen 2.46.0+** (`brew install xcodegen`)
- **Swift 6.2+ compiler**; the app stays in Swift 5 language mode and local packages use Swift 6
- **Apple Developer Account** (for code signing)

### Installation & Setup

1. **Clone the Repository**

   ```bash
   git clone https://github.com/heikopanjas/dashboard-of-doom-mac.git
   cd dashboard-of-doom-mac
   ```

2. **Generate and Open the Project**

   ```bash
   xcodegen generate
   open DashboardOfDoom.xcodeproj
   ```

   `project.yml` is the source of truth for targets, build settings, package
   dependencies, and the shared scheme. Run `xcodegen generate` after cloning
   and before building, especially after pulling changes or editing the spec.
   Generated project files are ignored; changes made directly in Xcode's
   project editor are overwritten by regeneration.

3. **Configure Signing**

   The specification preserves the existing manual Developer ID signing:
   team `8J2G689FCZ`, bundle ID `com.panjas.dashboard-of-doom`, and provisioning
   profile `Dashboard of Doom macOS`. Running or distributing the app requires
   the corresponding certificate and profile, including WeatherKit support.
   For a different team, update the signing settings in `project.yml`, including
   the `sdk=macosx*` overrides, and regenerate. Keep the WeatherKit entitlement
   in `DashboardOfDoom/DashboardOfDoom.entitlements`.

4. **Build and Run**
   - Select the `DashboardOfDoom` scheme and "My Mac" destination
   - Build and run (⌘R)
   - Grant location permissions when prompted
   - Menu bar icon will appear in the system tray

### Build Script

Run the executable script from the repository root (or invoke it by its path
from another directory). It regenerates the Xcode project before each build.

| Command | Action | Output |
| --- | --- | --- |
| `./build.sh` | Signed Debug build | `.build/Products/Debug/Dashboard of Doom.app` |
| `./build.sh --clean` | Delete build outputs and exit | Removes root `.build/`, `Build/`, and legacy `build/` |
| `./build.sh --release` | Signed Release build | `.build/Products/Release/Dashboard of Doom.app` |
| `./build.sh --notarize` | Archive Release, export, notarize, staple, verify | `.build/export/Dashboard of Doom.app` and `.build/Dashboard of Doom.zip` |

Combine `--clean` with `--release` or `--notarize` to clean before that operation.
For a clean Debug build, run `./build.sh --clean` followed by `./build.sh`.
Cleaning removes compiled products, intermediate files, caches, archives, and
exports in those root directories. It preserves sources, the package lockfile,
and build folders inside `Packages/`. The script fixes output paths explicitly
so machine-specific Xcode preferences do not redirect its artifacts.

Notarization uses `exportOptions.plist` for Developer ID export and the existing
Keychain credential profile `DashboardOfDoom-Notarize`. Set up credentials once:

```bash
xcrun notarytool store-credentials DashboardOfDoom-Notarize
```

To use another stored profile:

```bash
NOTARIZE_PROFILE=YourProfile ./build.sh --notarize
```

`--notarize` uploads the exported app to Apple and waits for the result. It staples
only an accepted submission, validates the ticket, checks Gatekeeper acceptance,
and recreates the ZIP with the stapled app. Submission output remains at
`.build/notarization-result.plist` for diagnosis. The archive is retained at
`.build/Dashboard of Doom.xcarchive`. See Apple's
[notarization workflow](https://developer.apple.com/documentation/security/customizing-the-notarization-workflow).

For a compile check without signing credentials:

```bash
xcodegen generate
xcodebuild -project DashboardOfDoom.xcodeproj \
  -scheme DashboardOfDoom -configuration Debug \
  -destination 'platform=macOS' -derivedDataPath Build/DerivedData \
  -disableAutomaticPackageResolution CODE_SIGNING_ALLOWED=NO build
```

Use a signed build to verify WeatherKit, location permissions, and menu bar
behavior at runtime.

The LaunchAtLogin dependency retains its `main` branch requirement and the revision
recorded in `DashboardOfDoom.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved`.
This lockfile remains tracked even though the rest of the project is generated.
Keep lockfile changes intentional when updating dependencies. Initial package
checkout requires network access.

See [package validation](PACKAGE_VALIDATION.md) for completed checks and remaining
interactive smoke tests.

The five local packages declare macOS 15 and iOS 26; only macOS is validated.
The app remains macOS-only, using Swift 5 language mode. See
[DoomKitLocation](doom-kit-location/README.md),
[DoomKitNetwork](doom-kit-network/README.md),
[DoomKitProcess](doom-kit-process/README.md),
[DoomKitTools](doom-kit-tools/README.md), and
[DoomKitServices](doom-kit-services/README.md) for API and lifecycle contracts.
Native location live updates are a planned provider replacement, not implemented
in this extraction. iOS integration and validation remain deferred.

Run package tests before the signed app build:

```bash
swift test --package-path doom-kit-location
swift test --package-path doom-kit-network
swift test --package-path doom-kit-process
swift test --package-path doom-kit-tools
swift test --package-path doom-kit-services
swift test -c release --package-path doom-kit-process
swift test -c release --package-path doom-kit-tools
swift test -c release --package-path doom-kit-services
./build.sh
./build.sh --release
```

There is currently no app test target. Build script tests use Python 3 and mock
external tools, including notarization; they perform no uploads:

```bash
python3 -m unittest discover -s tests -v
bash -n build.sh
shellcheck build.sh
```

Install ShellCheck with `brew install shellcheck` if needed. Define future app
test targets in `project.yml`.

### Permissions & Configuration

- **Location Services**: Required for geographic data filtering and location-based environmental data
- **Network Access**: Essential for API communication with German federal data sources
- **Notifications**: Optional for civil protection alerts and hazard warnings

## 🧩 Development & Contribution

### Code Architecture Principles

1. **Separation of Concerns**: Clear boundaries between data, business logic, and presentation
2. **Reactive Programming**: Observable state management with SwiftUI integration
3. **Error Resilience**: Comprehensive error handling and recovery mechanisms
4. **Performance Optimization**: Efficient data processing and memory management
5. **Menu Bar Optimization**: Lightweight operation with minimal system resource usage

### Development Workflow

```bash
# Development branch workflow
git checkout develop
git pull origin develop

# Create feature branch
git checkout -b feature/your-feature-name

# Make changes and commit
git add .
git commit -m "feat: add your feature description"

# Push and create pull request
git push origin feature/your-feature-name
```

### Testing Strategy

- **Unit Tests**: Core business logic and data transformations
- **Integration Tests**: API communication and data pipeline validation
- **UI Tests**: SwiftUI interface behavior and user interaction flows
- **Performance Tests**: Memory usage and data processing efficiency

## Data Quality & Reliability

### Quality Assessment System

- **Data Validation**: Real-time measurement verification
- **Confidence Scoring**: Statistical reliability assessment
- **Temporal Analysis**: Historical data consistency checking
- **Source Verification**: API endpoint health monitoring

### Update Frequencies

- **Weather Data**: 5-minute intervals
- **Air Quality**: 30-minute intervals
- **Water Levels**: 15-minute intervals
- **COVID-19 Data**: 6-hour intervals
- **Radiation Monitoring**: Real-time continuous updates
- **Civil Protection**: Immediate emergency notifications

## Privacy & Security

### Data Handling

- **Location Privacy**: GPS data processed locally, never transmitted
- **API Security**: Secure HTTPS communication with government endpoints
- **Data Retention**: Minimal local caching with automatic cleanup
- **User Control**: Granular privacy settings and data source toggles

---

Built with care in Swift for the German environmental monitoring community

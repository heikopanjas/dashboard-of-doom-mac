# Agent Instructions for Dashboard of Doom (macOS)

*Last updated: January 9, 2026 (Settings Reactivity - Sensor and Scope Options)*

## Project Overview

Dashboard of Doom is a sophisticated macOS menu bar application providing real-time environmental and public health data visualization for Germany. The application integrates with multiple German federal APIs to create an interactive, location-aware environmental monitoring system.

**Note**: This repository contains the **macOS-only** version. A separate iOS repository exists with similar architecture but platform-specific implementations.

### Current Implementation Status
- **Fully Functional**: Complete data pipeline from API integration to UI presentation
- **macOS Menu Bar App**: Lightweight menu bar extra with settings window
- **Production Ready**: Comprehensive error handling, retry mechanisms, and quality assessment
- **Modern Swift**: Utilizes Swift 5.0 concurrency features throughout the codebase
- **State Management**: Full `@Observable` implementation for reactive UI updates
- **Mathematical Analysis**: Advanced forecasting and trend analysis capabilities

## Architecture & Code Patterns

### Repository Structure
- **macOS-Only Repository**: This repo contains the macOS menu bar application
- **Shared Architecture**: Similar architecture patterns exist in the separate iOS repository
- **Platform-Specific**: Views and some Presenters contain macOS-specific implementations
- **Xcode Project**: Single .xcodeproj file for macOS target

### Platform Architecture
- **macOS**: MVP (Model-View-Presenter) pattern optimized for menu bar applications
- **Menu Bar Interface**: Lightweight status bar extra with popover/window presentation
- **Settings Window**: Dedicated configuration interface for user preferences
- **Shared Business Logic**: Controllers, Services, Models, and Utilities identical to iOS version

### Core Components

#### Data Flow Architecture
```
Controllers → Services → Transformers → Presenters → Views
```

1. **Controllers**: Orchestrate API communication and data parsing
2. **Services**: Handle HTTP requests to German federal APIs
3. **Transformers**: Process raw data into UI-ready formats with quality assessment
4. **Presenters**: Manage application state using `@Observable` macro
5. **Views**: SwiftUI interfaces with environment-based dependency injection

#### Key Design Patterns
- **Subscription System**: `ProcessManager` coordinates periodic data updates with configurable timeouts
- **Observer Pattern**: `ProcessSubscriber` protocol for reactive components with location-based updates
- **Transformer Pattern**: Clean separation of data processing from presentation logic
- **Quality Assessment**: Built-in measurement validation with `.good`, `.uncertain`, `.bad`, `.unknown` states
- **Mathematical Analysis**: Moving averages, exponential smoothing, and ARIMA forecasting
- **Unit Safety**: Custom `Dimension` subclasses with `@unchecked Sendable` conformance
- **Concurrent Processing**: All API calls and data transformations use structured concurrency

## Technology Stack

### Swift & SwiftUI
- **Swift 5.0**: Modern language features with structured concurrency
- **SwiftUI**: Cross-platform UI framework optimized for iOS 26.0+ and macOS 15.0+
- **WeatherKit**: Apple's native weather data framework for real-time conditions
- **@Observable**: iOS 17+ state management macro (primary state management pattern)
- **async/await**: Modern concurrency patterns throughout all controllers and services
- **Sendable**: Proper concurrency safety with `@unchecked Sendable` for custom unit types

### Data Sources & APIs
- **WeatherKit**: Apple's weather service for real-time weather data
- **BfS (Bundesamt für Strahlenschutz)**: Radiation monitoring
- **UBA (Umweltbundesamt)**: Air quality data (PM10, PM2.5, O3, NO2)
- **Pegelonline**: Federal waterway and shipping administration
- **NINA API**: National warning system for civil protection
- **Corona-Zahlen.org**: COVID-19 statistics
- **OpenStreetMap**: Geographic data and points of interest via Overpass API
- **DAWUM**: Political polling and survey data with categorical gradient visualization

## Code Style Guidelines

### Swift Conventions
- Use modern Swift 5.0 syntax with structured concurrency features
- Prefer `async/await` over completion handlers throughout the application
- Use `@Observable` for state management in all presenters
- Implement `@unchecked Sendable` for custom `Dimension` unit types
- Follow Swift API Design Guidelines with clear, descriptive naming
- Use meaningful, descriptive variable and function names
- Ensure thread safety with proper `Sendable` conformance where needed

### SwiftUI Best Practices
- Environment-based dependency injection for presenters
- Prefer `@State` and `@Environment` for data flow
- Use platform-specific code with `#if os(iOS)` / `#if os(macOS)`
- Implement proper view hierarchies and modifiers

### Architecture Patterns
- Controllers should handle data orchestration only
- Services should be stateless and handle pure HTTP communication
- Transformers should process data without side effects
- Presenters should manage state and provide data to views
- Views should be passive and reactive to state changes

## Data Processing

### Quality Assessment System
- **Four-Tier Quality**: `.good`, `.uncertain`, `.bad`, `.unknown` quality states
- **Temporal Validation**: Data consistency checks across time series
- **Confidence Scoring**: Automatic quality assessment based on data freshness and source reliability
- **Graceful Degradation**: Handle missing or invalid data with appropriate fallbacks
- **Custom Data Fields**: Support for additional metadata in `ProcessValue` structures

### Mathematical Analysis Capabilities
- **Moving Averages**: Simple and exponential moving averages for trend smoothing
- **ARIMA Forecasting**: Autoregressive integrated moving average predictions
- **Interpolation**: Gap filling for missing data points in time series
- **Nowcasting**: Real-time current value estimation from recent trends
- **Statistical Processing**: Advanced statistical analysis for data validation

### Measurement Units
- Use Foundation's `Measurement` and `Unit` types
- Support automatic unit conversion and standardization
- Display units with proper formatting and localization

### Mathematical Symbols
- Use Unicode mathematical symbols for data presentation:
  - Ω (Omicron) for COVID-19 data
  - Γ (Gamma) for radiation data
  - ρμ (Rho Mu) for particle data
  - τ (Tau) for temperature
  - η (Eta) for water levels
  - ν (Nu) for survey data

### Data Visualization Patterns
- **Gradient Color Coding**: Sophisticated gradient systems for categorical data representation
- **Political Data Visualization**: Custom gradient mappings for survey data with semantic color associations
- **Environmental Gradients**: Color-coded severity scales for air quality, radiation, and water levels
- **Temporal Visualization**: Trend indicators with mathematical forecasting display

## Network & Error Handling

### HTTP Communication Architecture
- **URLSession Extensions**: Custom `dataWithRetry` methods for resilient networking
- **Structured Concurrency**: All network calls use async/await patterns
- **Automatic Retries**: Exponential backoff retry mechanisms built into URLSession extension
- **Timeout Management**: Configurable timeouts for different data source types
- **Connection Monitoring**: Network availability detection via NetworkManager actor
- **HTTPS Enforcement**: All external API communications use secure protocols

### Error Management
- Comprehensive error handling throughout the data pipeline
- Graceful degradation when APIs are unavailable
- User-friendly error messages and recovery options
- Trace utility for structured logging and debugging

## Platform-Specific Considerations

### macOS Menu Bar Application
- Lightweight menu bar extra with current conditions
- Settings window for configuration
- Dark mode optimization
- Native macOS appearance integration
- System tray icon with real-time status updates
- Popover interface for quick data access

## Testing Guidelines

### Unit Testing
- Test core business logic in controllers and transformers
- Mock external API dependencies
- Validate data processing and quality assessment logic
- Test measurement calculations and unit conversions

### Integration Testing
- Validate API communication and response parsing
- Test data pipeline from service to presenter
- Verify error handling and retry mechanisms

### UI Testing
- Test SwiftUI interface behavior and user interactions
- Validate cross-platform compatibility
- Test accessibility and localization features

## Security & Privacy

### Data Protection
- Process GPS data locally, never transmit location
- Implement secure HTTPS communication
- Minimal local data caching with automatic cleanup
- Respect user privacy settings and data source toggles

### API Security
- Use secure endpoints for government data sources
- Implement proper authentication where required
- Handle API rate limiting and usage quotas

## Performance Optimization

### Memory Management
- Efficient data processing and transformation
- Proper cleanup of network resources
- Memory-conscious caching strategies

### Data Updates & Subscription System
- **ProcessManager**: Centralized subscription coordinator with location-based updates
- **ProcessSubscriber Protocol**: Standardized interface for reactive data consumers
- **ProcessSubscription**: Individual subscription management with configurable timeouts
- **Intelligent Refresh**: Different intervals based on data type and update frequency:
  - Weather: Real-time updates with 5-minute fallback
  - Air Quality: 30-minute intervals with immediate alerts
  - Water Levels: 15-minute intervals for hydrological data
  - COVID-19: 6-hour intervals for epidemiological data
  - Radiation: Continuous real-time monitoring
  - Civil Protection: Immediate push notifications for alerts
  - Political Surveys: Daily updates with trend analysis

### Implemented Utilities
- **ARIMA**: Autoregressive integrated moving average forecasting
- **MovingAverage**: Simple and exponential moving average calculations
- **HaversineDistance**: Geographic distance calculations
- **PointInPolygon**: Spatial geometry operations
- **PolygonProximityCalculator**: Distance to polygon calculations
- **OSMUtilities**: OpenStreetMap data processing helpers
- **MathematicalSymbols**: Unicode symbols for data visualization
- **Trace**: Structured logging utility for debugging and monitoring

## Development Workflow

### Git Conventions

**Branch Strategy:**
- Main development branch: `develop`
- Feature branches: `feature/<description>`
- Fix branches: `fix/<description>`
- Create pull requests for review before merging to `develop`

**Commit Message Format (Conventional Commits):**

Follow these rules strictly to prevent terminal crashes and maintain clean git history:

```text
<type>(<scope>): <subject>

<body>

<footer>
```

**Commit Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code formatting (no functional changes)
- `refactor`: Code restructuring (no functional changes)
- `test`: Adding or updating tests
- `chore`: Maintenance tasks
- `build`: Build system changes
- `ci`: CI/CD configuration changes
- `perf`: Performance improvements

**Character Limits (CRITICAL):**
- Subject line: Maximum 50 characters (strict limit)
- Body lines: Wrap at 72 characters per line
- Total message: Keep under 500 characters
- Always add blank line between subject and body

**Subject Line Rules:**
- Scope is optional but recommended: `feat(api):`, `fix(build):`, `docs(readme):`
- Use imperative mood: "add feature" not "added feature"
- No period at end of subject line
- Keep concise and descriptive

**Body Guidelines:**
- Explain what and why, not how
- Use bullet points (`-`) for multiple items
- Start bullet items with lowercase
- Keep concise and focused

**Special Character Safety:**
- Avoid nested quotes or complex quoting
- Avoid shell characters: `$`, `` ` ``, `!`, `\`, `|`, `&`, `;`
- Use simple punctuation only
- No emoji or unicode characters

**Best Practices:**
- Break up large commits into smaller, focused commits
- One concern per commit
- Test before committing
- Reference issues with `#123` format in footer if applicable

**Good Examples:**

```text
feat(api): add KStringTrim function

- add trimming function to remove whitespace from
  both ends of string
- supports all encodings
```

```text
fix(build): correct static library output name
```

**Bad Examples:**

```text
feat(api): add a new comprehensive string trimming function that handles all edge cases including UTF-8, UTF-16LE, UTF-16BE, and ANSI encodings with proper boundary checking and memory management
```
*Problem: Subject line exceeds 50 characters*

```text
fix: update `KString` with "nested 'quotes'" & $special chars!
```
*Problem: Contains special shell characters and complex quoting*


### Code Organization
- **macOS-Only Repository**: Single platform focus with dedicated macOS implementations
- **Shared Architecture Patterns**: Business logic patterns similar to the iOS repository
- **Platform-Specific Code**: macOS-specific UI and menu bar functionality
- **Custom Unit Types**: Implement `@unchecked Sendable` conformance for measurement units
- **Consistent Naming**: Use clear, descriptive file naming
- **Folder Hierarchy**: Maintain organized structure with Controllers/, Services/, Presenters/, Views/, etc.

## Common Tasks & Patterns

### Adding New Data Sources
1. **Create Service Class**: Implement async API communication methods
2. **Define Data Models**: Create parsing structures with proper error handling
3. **Implement Controller**: Add data orchestration with quality assessment
4. **Create Transformer**: Build UI-ready data processing with mathematical analysis
5. **Develop Presenter**: Implement `@Observable` presenter with `ProcessSubscriber` conformance
6. **Update Views**: Add environment injection and platform-specific UI code
7. **Configure Subscription**: Register with `ProcessManager` using appropriate timeout intervals
8. **Add Custom Units**: Implement `Dimension` subclasses with `@unchecked Sendable` if needed

### Implementing New Views
1. **Environment Injection**: Use `@Environment` for presenter dependencies
2. **Platform Conditionals**: Implement platform-specific layouts with `#if os()` directives
3. **State Management**: Follow `@Observable` patterns for reactive UI updates
4. **Accessibility**: Add proper accessibility labels and navigation support
5. **Localization**: Implement string localization for German market focus
6. **Error States**: Handle loading, error, and empty states gracefully

### Data Processing Workflow
1. **Service Layer**: Fetch raw data using async URLSession methods with retry logic
2. **Controller Layer**: Parse and validate data with comprehensive error handling
3. **Transformer Layer**: Process data with quality scoring and mathematical analysis
4. **Presenter Layer**: Publish processed data through `@Observable` properties
5. **View Layer**: Update UI reactively through environment injection and state binding
6. **Subscription Management**: Coordinate updates through `ProcessManager` with location awareness

Remember: This application focuses specifically on German environmental data and should maintain its regional focus while providing comprehensive, reliable monitoring capabilities.

## Current Development Notes

### Technology Status (Updated November 2025)
- **Swift Version**: Currently using Swift 5.0 with modern concurrency features
- **Deployment Targets**: iOS 26.0+ and macOS 15.0+ (verified in project settings)
- **Architecture Maturity**: Production-ready implementation with full feature set
- **Code Quality**: Comprehensive error handling, quality assessment, and mathematical analysis
- **Concurrency**: Full async/await adoption throughout the application stack
- **State Management**: Complete `@Observable` implementation for reactive programming
- **Network Resilience**: Advanced retry mechanisms via URLSession extensions with reachability monitoring

### Maintenance Guidelines
- Follow macOS Human Interface Guidelines for menu bar applications
- Maintain consistent API patterns across all service implementations
- Ensure proper `Sendable` conformance for new custom types
- Follow the established subscription pattern for new data sources
- Preserve the mathematical analysis capabilities when extending functionality
- Test menu bar functionality and system integration when implementing new features

---

## Recent Updates & Decisions

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

### October 3, 2025
- **Documentation Cleanup**: Removed 'Contributing' section from README.md
- **Reasoning**: Streamlined documentation by removing contribution guidelines, focusing on core project documentation and features

### August 22, 2025
- **Documentation Enhancement**: Added macOS screenshots section to README.md showcasing application UI with four key views (main dashboard, forecast, environment, particles)
- **File Organization**: Moved copilot instructions from root directory to `.github/` for better project structure and GitHub integration
- **README Structure**: Enhanced documentation with professional screenshot layout and maintained existing comprehensive feature descriptions
- **Political Data Visualization**: Added election poll screenshots (state and federal) to showcase comprehensive political polling capabilities
- **Reasoning**: Improved project presentation for potential contributors and users while organizing development guidelines in standard GitHub directory structure

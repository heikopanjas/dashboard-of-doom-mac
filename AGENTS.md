# GitHub Copilot Instructions for Dashboard of Doom

*Last updated: November 4, 2025*

## Project Overview

Dashboard of Doom is a sophisticated iOS SwiftUI application providing real-time environmental and public health data visualization for Germany. The application integrates with multiple German federal APIs to create an interactive, location-aware environmental monitoring system.

**Note**: This repository contains the iOS application. A separate macOS repository exists for the menu bar application variant.

### Current Implementation Status
- **Fully Functional**: Complete data pipeline from API integration to UI presentation
- **iOS Native**: Full-featured iOS application with interactive dashboard interface
- **Production Ready**: Comprehensive error handling, retry mechanisms, and quality assessment
- **Modern Swift**: Utilizes Swift 5.0 concurrency features throughout the codebase
- **State Management**: Full `@Observable` implementation for reactive UI updates
- **Mathematical Analysis**: Advanced forecasting and trend analysis capabilities

## Architecture & Code Patterns

### Repository Structure
- **iOS Application**: Single Xcode project for iOS platform
- **Standalone**: Independent from macOS variant (separate repository)
- **Shared Patterns**: Common architectural patterns applicable across platform variants
- **Code Organization**: Controllers/, Services/, Presenters/, Views/, Models/, Units/, Utilities/

### Platform Architecture
- **iOS**: MVVM (Model-View-ViewModel) pattern with reactive data binding
- **Full-Screen Interface**: Interactive dashboard with environmental data visualization
- **Location-Aware**: Background location updates and real-time data refresh
- **Native iOS**: Optimized for iPhone and iPad with responsive layouts

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
- **SwiftUI**: iOS-native UI framework optimized for iOS 26.0+
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
- Use `#if os(iOS)` for any platform-specific code patterns
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

### iOS Application
- Full-screen dashboard interface
- Interactive maps with environmental overlays
- Background location updates and data refresh
- Handle app lifecycle and background processing

### macOS Menu Bar Application (Separate Repository)
- Separate repository maintains macOS variant
- Shared architectural patterns but independent codebase
- Menu bar extra with lightweight current conditions display

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
- **iOS Single-Platform Structure**: Organized folder hierarchy within single Xcode project
- **Business Logic**: Controllers, Services, Models, and Units in dedicated folders
- **Platform-Optimized Code**: iOS-specific implementations without cross-platform conditionals
- **Custom Unit Types**: Implement `@unchecked Sendable` conformance for measurement units
- **Consistent Naming**: Use clear, descriptive file naming throughout project
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
2. **iOS-Optimized Layouts**: Implement responsive layouts for iPhone and iPad
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
- Maintain consistent API patterns across all service implementations
- Ensure proper `Sendable` conformance for new custom types
- Follow the established subscription pattern for new data sources
- Preserve the mathematical analysis capabilities when extending functionality
- Test thoroughly on both iPhone and iPad form factors

---

## Recent Updates & Decisions

### November 4, 2025 (README Update)
- **README iOS Focus**: Updated README.md to reflect iOS-only repository scope
- **Repository Links**: Added reference to separate macOS repository with correct GitHub links
- **Screenshots Section**: Updated to note iOS application with temporary placeholder for screenshots
- **Project Structure**: Simplified to show single Xcode project structure without platform folders
- **Installation Steps**: Streamlined setup instructions for iOS-only development
- **Features & Architecture**: Removed macOS-specific sections and emphasized iOS native capabilities
- **Testing Strategy**: Updated to focus on iPhone and iPad form factors
- **Related Projects**: Added section linking to macOS repository variant
- **Reasoning**: Aligned README documentation with repository separation to provide accurate information for iOS-focused development while maintaining reference to macOS variant

### November 4, 2025 (Repository Separation)
- **iOS Repository Isolation**: Updated AGENTS.md to reflect separation of iOS and macOS into independent repositories
- **Architecture Documentation**: Revised all cross-platform references to focus on iOS-only implementation
- **Platform-Specific Patterns**: Removed dual-platform maintenance guidelines and macOS-specific code patterns
- **Repository Structure**: Updated to reflect single Xcode project structure without platform conditionals
- **Maintenance Scope**: Changed testing requirements from "both platforms" to "iPhone and iPad form factors"
- **Reasoning**: Project has been split into separate iOS (this repo) and macOS (separate repo) repositories, requiring documentation to accurately reflect iOS-only scope while noting macOS variant exists independently

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

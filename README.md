# Dashboard of Doom (iOS)

![Swift 6.0](https://img.shields.io/badge/Swift-6.0-orange.svg)
![iOS 18.0+](https://img.shields.io/badge/iOS-18.0+-blue.svg)
![MIT License](https://img.shields.io/badge/License-MIT-green.svg)

**Dashboard of Doom** is a sophisticated iOS SwiftUI application that provides real-time environmental and public health data visualization for Germany. This comprehensive monitoring dashboard aggregates data from multiple German government and public APIs to create an interactive, location-aware environmental monitoring system.

> **Note**: This repository contains the iOS application. A separate [macOS repository](https://github.com/heikopanjas/dashboard-of-doom-macos) exists for the menu bar application variant.

> **Regional Focus**: This application is specifically designed for use in Germany and integrates with German federal data sources.

## Screenshots

### iOS Application

<div align="center">

**Main Dashboard**
![iOS Main Dashboard](images/macos-main.png)

**Weather Forecast**
![iOS Weather Forecast](images/macos-forecast.png)

**Environmental Monitoring**
![iOS Environmental Data](images/macos-environment.png)

**Particle Analysis**
![iOS Particle Data](images/macos-particles.png)

**State Election Polls**
![iOS State Election Polls](images/macos-state.png)

**Federal Election Polls**
![iOS Federal Election Polls](images/macos-federal.png)

</div>

> **Note**: Screenshots shown are from the original cross-platform version. iOS-specific screenshots will be updated soon.

## Features

### iOS Application

- **Interactive Dashboard**: Full-screen interface with comprehensive data visualization
- **Real-time Maps**: Location-aware environmental condition overlays
- **Chart Visualizations**: Advanced charts using Swift Charts framework
- **Multi-category Navigation**: Seamless switching between data categories
- **Background Updates**: Continuous location-based data refreshing
- **iPhone & iPad Support**: Responsive layouts optimized for all iOS devices

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

- **iOS**: MVVM (Model-View-ViewModel) architecture with reactive data binding
- **Full-Screen Interface**: Interactive dashboard with environmental data visualization
- **Location-Aware**: Background location updates and real-time data refresh
- **Native iOS**: Optimized for iPhone and iPad with responsive layouts

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

- **Subscription System**: `ProcessManager` coordinates periodic data updates
- **Observer Pattern**: `ProcessSubscriber` protocol for reactive components
- **Transformer Pattern**: Clean separation of data processing from presentation
- **Quality Assessment**: Built-in measurement validation and confidence scoring

## Technical Implementation

### Modern Swift Features

- **Swift 6.0**: Latest language features and strict concurrency
- **Concurrency**: Comprehensive async/await implementation
- **Observable Macro**: iOS 17+ state management with `@Observable`
- **Environment Injection**: SwiftUI environment-based dependency management
- **Native iOS**: Optimized for iOS platform with native frameworks

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
dashboard-of-doom-ios/
├── DashboardOfDoom/                  # iOS Application
│   ├── Controllers/                  # Data orchestration layer
│   ├── Services/                     # API communication services
│   ├── Presenters/                   # State management (MVVM)
│   ├── Transformers/                 # Data processing pipeline
│   ├── Views/                        # SwiftUI user interfaces
│   ├── Models/                       # Core data structures
│   ├── Extensions/                   # Swift utility extensions
│   ├── Units/                        # Measurement unit definitions
│   └── Utilities/                    # Helper functions and tools
├── DashboardOfDoom.xcodeproj/        # Xcode project
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

- **iOS 18.0+** (for device deployment)
- **Xcode 16.3+** with iOS 18 SDK
- **Swift 6.0+** compiler
- **Developer Account** (for device deployment)

### Installation & Setup

1. **Clone the Repository**

   ```bash
   git clone https://github.com/heikopanjas/dashboard-of-doom-ios.git
   cd dashboard-of-doom-ios
   ```

2. **Open the Project**

   ```bash
   open DashboardOfDoom.xcodeproj
   ```

3. **Configure Build Settings**
   - Select appropriate development team
   - Configure signing certificates
   - Set deployment target (iOS 18.0+)

4. **Build and Run**
   - Select iPhone/iPad simulator or connected device
   - Press ⌘R to build and run the application

### Permissions & Configuration

#### iOS Permissions

- **Location Services**: Required for location-based environmental data
- **Background App Refresh**: Enables continuous data updates
- **Network Access**: Essential for API communication

## 🧩 Development & Contribution

### Code Architecture Principles

1. **Separation of Concerns**: Clear boundaries between data, business logic, and presentation
2. **Reactive Programming**: Observable state management with SwiftUI integration
3. **Error Resilience**: Comprehensive error handling and recovery mechanisms
4. **Performance Optimization**: Efficient data processing and memory management
5. **iOS Native**: Optimized for iOS platform with native frameworks and patterns

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
- **Device Testing**: Validation on both iPhone and iPad form factors

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

Built with ❤️ in Swift for the German environmental monitoring community

## Related Projects

- [Dashboard of Doom (macOS)](https://github.com/heikopanjas/dashboard-of-doom-mac) - Menu bar application variant

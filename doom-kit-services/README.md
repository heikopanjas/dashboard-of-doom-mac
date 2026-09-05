# DoomKitServices

Local Swift 6 package, Swift tools 6.2, macOS 15 and iOS 26. macOS is validated;
iOS remains unvalidated. Direct local dependencies are DoomKitLocation,
DoomKitNetwork, and DoomKitTools. There is no Process dependency.

The seven public service classes are `CovidService`, `HazardService`,
`LevelService`, `ParticleService`, `PointOfInterestService`, `RadiationService`,
and `SurveyService`. All 25 public static fetch methods preserve their original
labels, defaults, URLs, encoding, and `async throws -> Data?` contract.

Every fetch method adds a trailing `networkManager: NetworkManager = .shared`
parameter. The injected manager handles both requests and connectivity checks:

```swift
import Foundation
import DoomKitNetwork
import DoomKitServices

func load(using manager: NetworkManager) async throws -> Data? {
    return try await RadiationService.fetchStations(networkManager: manager)
}
```

Successful
response bytes pass through untouched. Network failures, including cancellation,
continue to return nil. Retry, readiness, and monitoring policy stays in
DoomKitNetwork. Shared logging and bounding boxes come from DoomKitTools.

Particle requests retain the current calendar's hour from the `from` date for
both time parameters. A small internal formatter preserves the app's
`yyyy-MM-dd` formatting with default locale/calendar/time zone. General Date
extensions, parsing, controllers, presenters, transformers, and WeatherKit
integration remain in the app.

Run `swift test --package-path doom-kit-services` and repeat with `-c release`.
Tests use ordinary imports and cover all 25 methods against URL fixtures captured
from the original services: success byte preservation, server failure retries,
transport cancellation, and cancellation before requests. Transport, monitoring,
and timing are injected; there is no live networking or permission request.

# DoomKitTools

Local Swift 6 package, Swift tools 6.2, macOS 15 and iOS 26. macOS is validated;
iOS remains unvalidated. Its only local dependency is DoomKitLocation. It has
no dependency on process models, services, or SwiftUI.

Public APIs include `ARIMAPredictor`, its parameter/result/interval/error types,
`MathematicalSymbols`, `calculateBoundingBox`, `PolygonProximityCalculator`,
`FastPolygonProximity`, `LocationAnalysis`, and Location distance extensions.
Standalone types have separate files; usage examples remain internal.
Forecasting, geometry, and symbol mappings retain their original algorithms and
values. Mutable predictors and precomputed polygon calculators belong to one
caller at a time; they are not Sendable.

## Smoothing

All three functions accept and return `[Measurement<T>]` for `T: Dimension`:

```swift
import Foundation
import DoomKitTools

let values = [1.0, 4, 2].map { Measurement(value: $0, unit: UnitLength.meters) }
let result = gaussianSmoothing(data: values, windowSize: 5, sigma: 1.0)
```

`movingAverage(data:windowSize:)` uses a trailing window, shortened at the start.
Nonpositive windows return the input. `exponentialMovingAverage(data:alpha:)`
seeds from the first value and preserves the original recurrence. Both retain
the original raw-value arithmetic and use the first input unit for every output;
they do not convert mixed units.

`gaussianSmoothing(data:windowSize:sigma:)` defaults to 5 and 1.0. It converts
neighbors to each output's original unit, normalizes the truncated edge weights,
and clamps negative results to zero. Nonpositive or even windows, or nonpositive
or nonfinite sigma, return the input unchanged. Empty input always returns empty.

The app owns ProcessValue reconstruction: zip each original value with its
smoothed measurement, preserving timestamp, quality, and metadata, with a new UUID.

## Logging

`Trace` is a final, synchronously callable Sendable class. A `Synchronization.Mutex`
serializes date formatting and console/file output. It closes its file handle on
teardown, appends to existing files, and retains variadic logging overloads.
Filtering intentionally preserves the original lexical comparison of level raw
values (so ERROR sorts before INFO). No logging actor or unchecked Sendable was
introduced. The public global `trace` retains debug minimum, no colors, and
`yyyy-MM-dd HH:mm:ss` timestamps.

Run `swift test --package-path doom-kit-tools` and repeat with `-c release`.
Ordinary-import tests cover captured pre-extraction smoothing and forecast
results, invalid smoothing parameters, mixed units, geometry, symbol mappings,
and concurrent file logging. Tests do not access the network or location provider.

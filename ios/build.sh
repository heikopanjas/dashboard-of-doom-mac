#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd -P)"
CONFIGURATION=Debug
PLATFORM=simulator
SIMULATOR_ID=""
RUN=false

usage() {
    cat <<'HELP'
Usage: ./ios/build.sh [--release] [--device | --simulator UUID] [--run]

Build iOS with the root XcodeGen specification. No files are cleaned.
  --release         Use Release instead of Debug
  --device          Signed generic iOS device build, using automatic signing
  --simulator UUID  Build for a specific simulator (unsigned)
  --run             Boot that simulator, set HKW, install, and launch
  -h, --help        Show this help

Default: unsigned generic iOS simulator Debug build.
Outputs: .build/ios/{simulator,device}/{Debug,Release}/Products/
HKW: 52.51889, 13.36528. Location permission is still controlled by iOS.
Device builds require the existing team signing credentials and profile.
This script does not archive, export, upload, or change provisioning settings.
HELP
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --release) CONFIGURATION=Release; shift ;;
        --device) PLATFORM=device; shift ;;
        --simulator)
            [[ $# -ge 2 && "$2" != --* ]] || { echo '--simulator requires a UUID' >&2; exit 2; }
            SIMULATOR_ID="$2"; shift 2 ;;
        --run) RUN=true; shift ;;
        -h|--help) usage; exit 0 ;;
        *) printf 'Unknown option: %s\n' "$1" >&2; usage >&2; exit 2 ;;
    esac
done

if [[ "$PLATFORM" == device && ( -n "$SIMULATOR_ID" || "$RUN" == true ) ]]; then
    echo '--device cannot be combined with --simulator or --run' >&2
    exit 2
fi
if [[ "$RUN" == true && -z "$SIMULATOR_ID" ]]; then
    echo '--run requires --simulator UUID' >&2
    exit 2
fi
for tool in xcodegen xcodebuild xcrun; do
    command -v "$tool" >/dev/null || { echo "Required tool missing: $tool" >&2; exit 1; }
done

cd -- "$REPO_DIR"
xcodegen generate
BUILD_DIR="${REPO_DIR}/.build/ios/${PLATFORM}/${CONFIGURATION}"
ARGS=(
    -project DashboardOfDoom.xcodeproj -scheme DashboardOfDoom-iOS
    -configuration "$CONFIGURATION" -derivedDataPath "${BUILD_DIR}/DerivedData"
    -disableAutomaticPackageResolution
    "SYMROOT=${BUILD_DIR}/Products" "OBJROOT=${BUILD_DIR}/Intermediates"
)
if [[ "$PLATFORM" == device ]]; then
    ARGS+=(-destination 'generic/platform=iOS')
else
    DESTINATION='generic/platform=iOS Simulator'
    if [[ -n "$SIMULATOR_ID" ]]; then DESTINATION="platform=iOS Simulator,id=${SIMULATOR_ID}"; fi
    ARGS+=(-destination "$DESTINATION" CODE_SIGNING_ALLOWED=NO)
fi
xcodebuild "${ARGS[@]}" build

if [[ "$RUN" == true ]]; then
    # bootstatus -b boots a shutdown device and waits for launch services.
    xcrun simctl bootstatus "$SIMULATOR_ID" -b
    xcrun simctl location "$SIMULATOR_ID" set 52.51889,13.36528
    xcrun simctl install "$SIMULATOR_ID" "${BUILD_DIR}/Products/${CONFIGURATION}-iphonesimulator/Dashboard of Doom.app"
    xcrun simctl launch --terminate-running-process "$SIMULATOR_ID" com.panjas.dashboard-of-doom
fi

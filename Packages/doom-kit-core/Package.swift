// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "doom-kit-core",
    platforms: [
        .macOS(.v15),
        .iOS("26")
    ],
    products: [
        .library(name: "DoomKitCore", targets: ["DoomKitCore"])
    ],
    targets: [
        .target(name: "DoomKitCore"),
        .testTarget(
            name: "DoomKitCoreTests",
            dependencies: ["DoomKitCore"]
        )
    ]
)

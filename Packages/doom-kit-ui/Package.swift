// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "doom-kit-ui",
    platforms: [
        .macOS(.v15),
        .iOS("26")
    ],
    products: [
        .library(name: "DoomKitUI", targets: ["DoomKitUI"])
    ],
    dependencies: [
        .package(path: "../doom-kit-core")
    ],
    targets: [
        .target(
            name: "DoomKitUI",
            dependencies: [
                .product(name: "DoomKitCore", package: "doom-kit-core")
            ]
        ),
        .testTarget(
            name: "DoomKitUITests",
            dependencies: ["DoomKitUI"]
        )
    ]
)

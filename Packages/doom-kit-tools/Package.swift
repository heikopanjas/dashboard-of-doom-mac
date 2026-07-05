// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "doom-kit-tools",
    platforms: [
        .macOS(.v15),
        .iOS("26")
    ],
    products: [
        .library(name: "DoomKitTools", targets: ["DoomKitTools"])
    ],
    dependencies: [
        .package(path: "../doom-kit-core")
    ],
    targets: [
        .target(
            name: "DoomKitTools",
            dependencies: [
                .product(name: "DoomKitCore", package: "doom-kit-core")
            ]
        ),
        .testTarget(
            name: "DoomKitToolsTests",
            dependencies: ["DoomKitTools"]
        )
    ]
)

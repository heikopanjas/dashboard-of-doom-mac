// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "doom-kit-providers",
    platforms: [
        .macOS(.v15),
        .iOS("26")
    ],
    products: [
        .library(name: "DoomKitProviders", targets: ["DoomKitProviders"])
    ],
    dependencies: [
        .package(path: "../doom-kit-core"),
        .package(path: "../doom-kit-tools")
    ],
    targets: [
        .target(
            name: "DoomKitProviders",
            dependencies: [
                .product(name: "DoomKitCore", package: "doom-kit-core"),
                .product(name: "DoomKitTools", package: "doom-kit-tools")
            ],
            linkerSettings: [
                .linkedFramework("WeatherKit", .when(platforms: [.macOS, .iOS]))
            ]
        ),
        .testTarget(
            name: "DoomKitProvidersTests",
            dependencies: ["DoomKitProviders"]
        )
    ]
)

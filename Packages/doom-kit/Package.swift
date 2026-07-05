// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "doom-kit",
    platforms: [
        .macOS(.v15),
        .iOS("26")
    ],
    products: [
        .library(name: "DoomKit", targets: ["DoomKit"])
    ],
    dependencies: [
        .package(path: "../doom-kit-core"),
        .package(path: "../doom-kit-tools"),
        .package(path: "../doom-kit-providers"),
        .package(path: "../doom-kit-ui")
    ],
    targets: [
        .target(
            name: "DoomKit",
            dependencies: [
                .product(name: "DoomKitCore", package: "doom-kit-core"),
                .product(name: "DoomKitTools", package: "doom-kit-tools"),
                .product(name: "DoomKitProviders", package: "doom-kit-providers"),
                .product(name: "DoomKitUI", package: "doom-kit-ui")
            ]
        )
    ]
)

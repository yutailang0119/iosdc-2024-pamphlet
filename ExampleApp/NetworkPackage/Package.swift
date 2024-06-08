// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NetworkPackage",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
        .tvOS(.v17),
        .watchOS(.v10),
        .visionOS(.v1),
    ],
    products: [
        .library(
            name: "NetworkLibrary",
            targets: ["NetworkLibrary"]),
    ],
    targets: [
        .target(
            name: "NetworkLibrary",
            dependencies: [
                "BonjourExample",
                "UDPExample",
            ]),
        .target(
            name: "BonjourExample"),
        .target(
            name: "UDPExample"),
    ]
)

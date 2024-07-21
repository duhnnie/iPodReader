// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "iPodReader",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "iPodReader",
            targets: ["iPodReader"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "iPodReader",
            dependencies: []),
        .testTarget(
            name: "iPodReaderTests",
            dependencies: ["iPodReader"],
            resources: [
                .copy("Resources")
            ]
        ),
    ]
)

// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WWFloatingActionButton",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(name: "WWFloatingActionButton", targets: ["WWFloatingActionButton"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "WWFloatingActionButton", resources: [.process("Xib")]),
    ],
    swiftLanguageVersions: [
        .v5
    ]
)

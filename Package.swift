// swift-tools-version: 5.7

import PackageDescription

let package = Package(name: "TinyFoundation", platforms: [
    .macOS(.v13), .iOS(.v16), .watchOS(.v9), .tvOS(.v16),
], products: [
    .library(name: "TinyFoundation", targets: ["Documents", "LibC", "Loop", "Math", "Process", "Signal", "Timestamp", "UniqueID", "Version"]),
], targets: [
    .target(name: "Documents", dependencies: [
        .target(name: "LibC"),
    ]),
    .target(name: "LibC", dependencies: [
        .target(name: "LibCExternal"),
    ], linkerSettings: [
        .linkedLibrary("android", .when(platforms: [.android])),
    ]),
    .systemLibrary(name: "LibCExternal"),
    .target(name: "Loop", dependencies: [
        .target(name: "LibC"),
    ]),
    .target(name: "Math", dependencies: [
        .target(name: "LibC"),
    ]),
    .target(name: "Process", dependencies: [
        .target(name: "LibC"),
    ], linkerSettings: [
        .linkedLibrary("android-spawn", .when(platforms: [.android])),
    ]),
    .target(name: "Signal", dependencies: [
        .target(name: "LibC"),
    ]),
    .target(name: "Timestamp", dependencies: [
        .target(name: "LibC"),
    ]),
    .target(name: "UniqueID", dependencies: [
        .target(name: "Timestamp"),
    ]),
    .target(name: "Version"),
])

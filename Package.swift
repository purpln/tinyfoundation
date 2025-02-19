// swift-tools-version: 6.0

import PackageDescription

let package = Package(name: "TinyFoundation", products: [
    .library(name: "TinyFoundation", targets: [
        "Documents", "LibC", "Loop", "Math", "Process", "Signal", "Socket", "Timestamp", "UniqueID", "Version"
    ]),
], targets: [
    .target(name: "Documents", dependencies: [
        "LibC"
    ]),
    .target(name: "LibC", dependencies: [
        "LibCExternal"
    ], linkerSettings: [
        .linkedLibrary("android", .when(platforms: [.android])),
    ]),
    .target(name: "LibCExternal"),
    .target(name: "Loop", dependencies: [
        "LibC"
    ]),
    .target(name: "Math", dependencies: [
        "MathExternal"
    ]),
    .systemLibrary(name: "MathExternal"),
    .target(name: "Process", dependencies: [
        "LibC"
    ], linkerSettings: [
        .linkedLibrary("android-spawn", .when(platforms: [.android])),
    ]),
    .target(name: "Signal", dependencies: [
        "LibC"
    ]),
    .target(name: "Socket", dependencies: [
        "LibC"
    ]),
    .target(name: "Timestamp", dependencies: [
        "LibC"
    ]),
    .target(name: "UniqueID", dependencies: [
        "Timestamp"
    ]),
    .target(name: "Version"),
])

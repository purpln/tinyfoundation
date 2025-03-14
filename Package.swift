// swift-tools-version: 6.0

import PackageDescription

let package = Package(name: "TinyFoundation", products: [
    .library(name: "TinyFoundation", targets: [
        "Documents", "Lock", "Loop", "Process", "Signal", "Socket", "Sorting", "Timestamp", "UniqueID", "Version"
    ]),
], dependencies: [
    .package(url: "https://github.com/purpln/libc.git", branch: "main"),
], targets: [
    .target(name: "Documents", dependencies: [
        .product(name: "LibC", package: "libc"),
    ]),
    .target(name: "Lock"),
    .target(name: "Loop", dependencies: [
        .product(name: "LibC", package: "libc"),
    ]),
    .target(name: "Process", dependencies: [
        .product(name: "LibC", package: "libc"),
    ], linkerSettings: [
        .linkedLibrary("android-spawn", .when(platforms: [.android])),
    ]),
    .target(name: "Signal", dependencies: [
        .product(name: "LibC", package: "libc"),
    ]),
    .target(name: "Socket", dependencies: [
        .product(name: "LibC", package: "libc"),
    ]),
    .target(name: "Sorting"),
    .target(name: "Timestamp", dependencies: [
        .product(name: "LibC", package: "libc"),
    ]),
    .target(name: "UniqueID", dependencies: [
        "Timestamp"
    ]),
    .target(name: "Version"),
])

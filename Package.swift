// swift-tools-version:5.7

import PackageDescription

let package = Package(name: "TinyFoundation", products: [
    .library(name: "TinyFoundation", targets: ["Coders", "Documents", "LibC", "Loop", "Process", "Signal", "Version"]),
], targets: [
    .target(name: "Coders"),
    .target(name: "Documents", dependencies: [
        .target(name: "LibC"),
    ]),
    .systemLibrary(name: "External"),
    .target(name: "LibC", dependencies: [
        .target(name: "External"),
    ]),
    .target(name: "Loop", dependencies: [
        .target(name: "LibC"),
    ]),
    .target(name: "Process", dependencies: [
        .target(name: "Documents"),
        .target(name: "LibC"),
        .target(name: "Loop"),
    ], linkerSettings: [
        .linkedLibrary("android-spawn", .when(platforms: [.android])),
    ]),
    .target(name: "Signal", dependencies: [
        .target(name: "LibC"),
    ]),
    .target(name: "Version"),
])

#if os(macOS)
package.platforms = [.macOS(.v13), .iOS(.v16), .watchOS(.v9), .tvOS(.v16)]
#endif

// swift-tools-version: 6.0

import PackageDescription

let package = Package(name: "TinyFoundation", products: [
    .library(name: "TinyFoundation", targets: [
        "Sorting", "Timestamp", "UniqueID", "Version"
    ]),
], dependencies: [
    .package(url: "https://github.com/purpln/libc.git", branch: "main"),
], targets: [
    .target(name: "Sorting"),
    .target(name: "Timestamp", dependencies: [
        .product(name: "LibC", package: "libc"),
    ]),
    .target(name: "UniqueID", dependencies: [
        "Timestamp"
    ]),
    .target(name: "Version"),
])

// swift-tools-version: 5.5

import PackageDescription

let package = Package(name: "TinyFoundation", products: [
    .library(name: "TinyFoundation", targets: ["TinyFoundation"]),
], dependencies: [
    .package(path: "../libc"),
], targets: [
    .target(name: "TinyFoundation", dependencies: [
        .product(name: "LibC", package: "libc"),
        "TinySystem",
    ]),
    .target(name: "TinySystem", dependencies: [
        .product(name: "LibC", package: "libc"),
    ]),
])

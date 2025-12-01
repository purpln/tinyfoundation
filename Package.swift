// swift-tools-version: 6.2

import PackageDescription

let package = Package(name: "TinyFoundation", products: [
    .library(name: "TinyFoundation", targets: ["TinyFoundation"]),
], dependencies: [
    .package(url: "https://github.com/purpln/libc.git", branch: "main"),
], targets: [
    .target(name: "TinyFoundation", dependencies: [
        .product(name: "LibC", package: "libc"),
        "TinySystem"
    ]),
    .target(name: "TinySystem", dependencies: [
        .product(name: "LibC", package: "libc"),
    ]),
])

for target in package.targets {
    target.swiftSettings = target.swiftSettings ?? []
    target.swiftSettings? += [
        //.strictMemorySafety(),
        
        //swift 6
        .enableUpcomingFeature("StrictConcurrency"),
        
        //swift 7
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableUpcomingFeature("ImmutableWeakCaptures"),
    ]
}

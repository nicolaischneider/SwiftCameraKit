// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftCameraKit",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(
            name: "SwiftCameraKit",
            targets: ["SwiftCameraKit"]),
    ],
    targets: [
        .target(
            name: "SwiftCameraKit"),

    ]
)

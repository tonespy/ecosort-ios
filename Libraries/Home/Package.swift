// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Home",
    defaultLocalization: "en",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "Home",
            targets: ["Home"]),
    ],
    dependencies: [
      .package(name: "Asset", path: "../Asset"),
      .package(name: "Platform", path: "../Platform")
    ],
    targets: [
        .target(
            name: "Home",
            dependencies: [
              .product(name: "Asset", package: "Asset"),
              .product(name: "Platform", package: "Platform")
            ]
        ),

    ]
)

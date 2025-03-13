// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Onboarding",
    defaultLocalization: "en",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "Onboarding",
            targets: ["Onboarding"]),
    ],
    dependencies: [
      .package(name: "Asset", path: "../Asset"),
      .package(name: "Platform", path: "../Platform")
    ],
    targets: [
        .target(
            name: "Onboarding",
            dependencies: [
              .product(name: "Asset", package: "Asset"),
              .product(name: "Platform", package: "Platform")
            ]
        ),

    ]
)

// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Platform",
    defaultLocalization: "en",
    platforms: [
      .iOS(.v17)
    ],
    products: [
      .library(
        name: "Platform",
        targets: ["Platform"]),
    ],
    dependencies: [
      .package(name: "Asset", path: "../Asset"),
      .package(name: "TensorFlowLiteSwift", path: "../TensorFlowLiteSwift")
    ],
    targets: [
      .target(
        name: "Platform",
        dependencies: [
          .product(name: "Asset", package: "Asset"),
          .product(name: "TensorFlowLiteSwift", package: "TensorFlowLiteSwift")
        ]
      ),
      .testTarget(
        name: "PlatformTests",
        dependencies: ["Platform"]),
    ]
)

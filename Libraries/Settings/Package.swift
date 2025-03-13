// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Settings",
  defaultLocalization: "en",
  platforms: [.iOS(.v17)],
  products: [
    .library(
      name: "Settings",
      targets: ["Settings"]),
  ],
  dependencies: [
    .package(name: "Asset", path: "../Asset"),
    .package(name: "Platform", path: "../Platform")
  ],
  targets: [
    .target(
      name: "Settings",
      dependencies: [
        .product(name: "Asset", package: "Asset"),
        .product(name: "Platform", package: "Platform")
      ]
    ),

  ]
)

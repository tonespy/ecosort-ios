// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Asset",
    defaultLocalization: "en",
    platforms: [
      .iOS(.v17)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Asset",
            targets: ["Assets"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Assets",
            dependencies: [],
            path: nil,
            exclude: ["SupportingFiles"],
            sources: nil,
            resources: [.process("Resources"), .process("Fonts")],
            publicHeadersPath: nil,
            cSettings: nil,
            cxxSettings: nil,
            swiftSettings: nil,
            linkerSettings: nil),
        .testTarget(
            name: "AssetTests",
            dependencies: ["Assets"]),
    ]
)

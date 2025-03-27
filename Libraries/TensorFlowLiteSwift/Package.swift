// swift-tools-version:6.0
import PackageDescription

let package = Package(
  name: "TensorFlowLiteSwift",
  platforms: [.iOS(.v12)],
  products: [
    .library(
      name: "TensorFlowLiteSwift",
      targets: ["TensorFlowLiteSwift"]
    ),
  ],
  targets: [
    // Binary target for the Swift framework.
    .binaryTarget(
      name: "TensorFlowLite",
      path: "./TensorFlowLite.xcframework"
    ),
    // Binary target for the C API framework.
    .binaryTarget(
      name: "TensorFlowLiteC",
      path: "./TensorFlowLiteC.xcframework"
    ),
    // A wrapper target that re-exports both frameworks.
    .target(
      name: "TensorFlowLiteSwift",
      dependencies: [
          "TensorFlowLite",
          "TensorFlowLiteC"
      ],
      path: "Sources/TensorFlowLiteWrapper"
    )
  ]
)

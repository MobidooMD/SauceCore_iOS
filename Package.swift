// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "SauceCore_iOS",
    products: [
        .library(
            name: "SauceCore_iOS",
            targets: ["SauceCore_iOS"]),
    ],
    targets: [
        .target(
            name: "SauceCore_iOS",
            resources: [
                .process("Assets")
            ]),
        .testTarget(
            name: "SauceCore_iOSTests",
            dependencies: ["SauceCore_iOS"]),
    ]
)

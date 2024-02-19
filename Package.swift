// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SauceCore_iOS",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SauceCore_iOS",
            targets: ["SauceCore_iOS"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SauceCore_iOS"),
        .testTarget(
            name: "SauceCore_iOSTests",
            dependencies: ["SauceCore_iOS"]),
    ]
)

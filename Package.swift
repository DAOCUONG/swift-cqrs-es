// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift_cqrs_es",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "swift_cqrs_es",
            targets: ["swift_cqrs_es"]),
    ],
    dependencies: [
    // Targets can depend on other targets in this package and products from dependencies.
    .package(url: "https://github.com/bow-swift/bow.git", from: "0.8.0"),
    .package(url: "https://github.com/groue/GRDB.swift.git", from: "6.20.2")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "swift_cqrs_es",
            dependencies:[.product(name: "BowRx", package: "bow"),.product(name: "Bow", package: "bow"),.product(name: "BowEffects", package: "bow")]),
        .testTarget(
            name: "swift_cqrs_esTests",
            dependencies: ["swift_cqrs_es",.product(name: "BowRx", package: "bow"),.product(name: "Bow", package: "bow"),.product(name: "BowEffects", package: "bow")]),
    ]
)

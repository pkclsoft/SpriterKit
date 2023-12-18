// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SpriterKit",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SpriterKit",
            targets: ["SpriterKit"]
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/pkclsoft/CGExtKit", branch: "main")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SpriterKit",
            dependencies:  ["CGExtKit"],
            path: "SpriterKit/Sources/SpriterKit"),
        .testTarget(
            name: "SpriterKitTests",
            dependencies: ["SpriterKit"],
            path: "SpriterKit/Tests/SpriterKitTests"),
    ]
)

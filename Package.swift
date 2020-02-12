// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ELBRUS",
    platforms: [
        .macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6)
    ],
    products: [
        .library(name: "ELBRUS", targets: ["ELBRUS"])
    ],
    dependencies: [
         .package(url: "https://github.com/vapor/codable-kit.git", .branch("master"))
    ],
    targets: [
        .target(
            name: "ELBRUS",
            dependencies: ["CodableKit"]),
        .testTarget(
            name: "ELBRUSTests",
            dependencies: ["ELBRUS"])
    ]
)

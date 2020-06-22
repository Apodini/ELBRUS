// swift-tools-version:5.2
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
        .package(name: "codable-kit",
                 url: "https://github.com/vapor/codable-kit.git",
                 .branch("master"))
    ],
    targets: [
        .target(
            name: "ELBRUS",
            dependencies: [
                .product(name: "CodableKit", package: "codable-kit")
            ]
        ),
        .testTarget(
            name: "ELBRUSTests",
            dependencies: [
                .target(name: "ELBRUS")
            ]
        )
    ]
)

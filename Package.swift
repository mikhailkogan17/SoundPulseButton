// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SoundPulseButton",
    platforms: [
        .iOS(.v17),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "SoundPulseButton",
            targets: ["SoundPulseButton"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/Lakr233/ColorfulX", from: "5.6.0")
    ],
    targets: [
        .target(
            name: "SoundPulseButton",
            dependencies: [
                "ColorfulX"
            ],
            path: "Sources"
        )
    ]
)

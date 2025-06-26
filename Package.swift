// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TheAmazingAudioEngine2",
    products: [
        .library(
            name: "TheAmazingAudioEngine2",
            targets: ["TheAmazingAudioEngine2"]),
    ],
    targets: [
        .target(
            name: "TheAmazingAudioEngine2",
            path: "Sources/TheAmazingAudioEngine2",
            exclude: [
                "src/Modules/Processing/AESampleRateConverter.m",
                "src/Modules/Generation/AEAudiobusInputModule.m",
            ],
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("src/Core"),
                .headerSearchPath("src/Library"),
                .headerSearchPath("src/Library/TPCircularBuffer"),
                .headerSearchPath("src/Modules"),
                .headerSearchPath("src/Modules/Generation"),
                .headerSearchPath("src/Modules/Processing"),
                .headerSearchPath("src/Modules/Taps"),
                .headerSearchPath("src/Outputs"),
                .headerSearchPath("src/Renderers"),
                .headerSearchPath("src/Utilities"),
            ]
        ),
        .testTarget(
            name: "TheAmazingAudioEngine2Tests",
            dependencies: ["TheAmazingAudioEngine2"]
        ),
    ]
)

// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "SprintBell",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "SprintBell", targets: ["SprintBell"])
    ],
    targets: [
        .executableTarget(
            name: "SprintBell",
            path: "src",
            exclude: ["Info.plist"],
            resources: [
                .copy("Audio/alarm.mp3")
            ]
        )
    ]
)
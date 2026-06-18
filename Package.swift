// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AdaptiveSidebarViewController",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "AdaptiveSidebarViewController",
            targets: ["AdaptiveSidebarViewController"]
        ),
    ],
    targets: [
        .target(
            name: "AdaptiveSidebarViewController",
            path: "Classes"
        ),
    ]
)

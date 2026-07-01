// swift-tools-version:5.9
import PackageDescription

/// FlowLingo iOS Package
///
/// This package defines the modules for the FlowLingo iOS app:
/// - FlowLingo (companion app)
/// - FlowLingoKeyboard (keyboard extension)
/// - FlowLingoShare (share extension)
/// - FlowLingoWidget (today widget)
/// - FlowLingoShared (shared models and services)
let package = Package(
    name: "FlowLingo",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "FlowLingoShared",
            targets: ["FlowLingoShared"]
        ),
    ],
    dependencies: [
        // No external dependencies required for the shell
        // In production, add:
        // .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.0.0"),
        // .package(url: "https://github.com/airbnb/lottie-ios.git", from: "4.0.0"),
    ],
    targets: [
        .target(
            name: "FlowLingoShared",
            dependencies: [],
            path: "Shared",
            resources: []
        ),
        .target(
            name: "FlowLingo",
            dependencies: ["FlowLingoShared"],
            path: "FlowLingo",
            resources: []
        ),
        .target(
            name: "FlowLingoKeyboard",
            dependencies: ["FlowLingoShared"],
            path: "KeyboardExtension",
            resources: []
        ),
        .target(
            name: "FlowLingoShare",
            dependencies: ["FlowLingoShared"],
            path: "ShareExtension",
            resources: []
        ),
        .target(
            name: "FlowLingoWidget",
            dependencies: ["FlowLingoShared"],
            path: "WidgetExtension",
            resources: []
        ),
    ]
)
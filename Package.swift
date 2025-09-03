// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ISPOrgMenuBarApp",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "ISPOrgMenuBarApp", targets: ["ISPOrgMenuBarApp"])
    ],
    targets: [
        .executableTarget(
            name: "ISPOrgMenuBarApp"
        )
    ]
)

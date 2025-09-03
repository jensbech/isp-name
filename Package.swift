// swift-tools-version: 6.2
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

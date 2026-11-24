// swift-tools-version: 6.2
import PackageDescription

let package = Package(
   name: "Site",
   platforms: [.macOS(.v26)],
   dependencies: [
      .package(url: "https://github.com/FlineDev/SiteKit.git", exact: "1.0.2"),
   ],
   targets: [
      .executableTarget(
         name: "Site",
         dependencies: [
            .product(name: "SiteKit", package: "SiteKit"),
         ]
      ),
   ]
)

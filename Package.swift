// swift-tools-version:3.1

import PackageDescription

let package = Package(
  name: "OSSMCore",
  targets: [
    Target(name: "Calendar"),
    Target(name: "Localization"),
    Target(name: "Geography", dependencies: ["Localization"]),
    Target(name: "Population", dependencies: ["Geography"]),
  ]
)

// swift-tools-version:3.1

import PackageDescription

let package = Package(
  name: "OSSMCore",
  targets: [
    Target(name: "Configuration", dependencies: ["Geography", "Localization", "Population"]),
    Target(name: "Calendar"),
    Target(name: "Localization"),
    Target(name: "Geography", dependencies: ["Localization"]),
    Target(name: "Population", dependencies: ["Geography"]),
  ],
  dependencies: [
    .Package(url: "https://github.com/vapor/random.git", Version(1,0,0, prereleaseIdentifiers: ["beta"])),
  ]
)

// swift-tools-version:3.1

import PackageDescription

let package = Package(
  name: "OSSMCore",
  dependencies: [
    .Package(url: "https://github.com/vapor/random.git", Version(1,0,0, prereleaseIdentifiers: ["beta"])),
    .Package(url: "https://github.com/vapor/fluent.git", Version(2,0,0, prereleaseIdentifiers: ["beta"])),
  ]
)

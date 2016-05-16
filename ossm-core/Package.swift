import PackageDescription

let package = Package(
  name: "ossm-core",
  targets: [
    Target(
      name: "ossm-api",
      dependencies: [
        .Target(name: "ossm-core")
      ]
    ),
    Target(
      name: "ossm-core"
    )
  ],
  dependencies: [
    .Package(url: "https://github.com/qutheory/vapor.git", Version(0, 8, 1)),
    .Package(url: "https://github.com/qutheory/csqlite.git", Version(0, 1, 0)),
    .Package(url: "https://github.com/Zewo/PostgreSQL.git", Version(0, 7, 0)),
  ]
)

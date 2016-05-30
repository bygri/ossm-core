import PackageDescription

let package = Package(
  name: "OSSMCore",
  targets: [
    Target(
      name: "OSSMApi",
      dependencies: [
        .Target(name: "OSSMCore")
      ]
    ),
    Target(
      name: "OSSMCore"
    )
  ],
  dependencies: [
    .Package(url: "https://github.com/qutheory/vapor.git", Version(0, 8, 1)),
    .Package(url: "https://github.com/qutheory/csqlite.git", Version(0, 1, 0)),
    .Package(url: "https://github.com/Zewo/PostgreSQL.git", Version(0, 7, 0)),
    .Package(url: "https://github.com/colemancda/CryptoSwift", Version(1, 1, 0)),
  ]
)

// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "first-service",
    dependencies: [
        .package(url:"https://github.com/IBM-Swift/Kitura.git", from: "0.7.9"),
        .package(url:"https://github.com/IBM-Swift/HeliumLogger.git",from : "0.7.9"),
            .package(url:"https://github.com/IBM-Swift/Kitura-CouchDB.git",from:"0.33.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(name: "first-service", dependencies: ["Kitura","HeliumLogger","Kitura-CouchDB"]),
    ]
)

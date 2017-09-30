// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "OracleDB",
    targets: [Target(name: "OracleDB", dependencies: ["Cocilib"])]
)

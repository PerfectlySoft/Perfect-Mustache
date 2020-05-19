// swift-tools-version:5.1
// Generated automatically by Perfect Assistant
// Date: 2018-05-31 18:31:13 +0000
import PackageDescription

let package = Package(
	name: "PerfectMustache",
	platforms: [
		.macOS(.v10_15)
	],
	products: [
		.library(name: "PerfectMustache", targets: ["PerfectMustache"])
	],
	dependencies: [
		.package(url: "https://github.com/PerfectlySoft/PerfectLib.git", from: "4.0.0"),
	],
	targets: [
		.target(name: "PerfectMustache", dependencies: ["PerfectLib"]),
		.testTarget(name: "PerfectMustacheTests", dependencies: ["PerfectMustache"])
	]
)

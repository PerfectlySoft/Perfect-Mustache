// swift-tools-version:4.0
// Generated automatically by Perfect Assistant
// Date: 2018-05-31 18:31:13 +0000
import PackageDescription

let package = Package(
	name: "PerfectMustache",
	products: [
		.library(name: "PerfectMustache", targets: ["PerfectMustache"])
	],
	dependencies: [
		.package(url: "https://github.com/PerfectlySoft/Perfect-Thread.git", from: "3.0.0"),
		.package(url: "https://github.com/PerfectlySoft/PerfectLib.git", from: "3.0.0"),
	],
	targets: [
		.target(name: "PerfectMustache", dependencies: ["PerfectThread", "PerfectLib"]),
		.testTarget(name: "PerfectMustacheTests", dependencies: ["PerfectMustache"])
	]
)

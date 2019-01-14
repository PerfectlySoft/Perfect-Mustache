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
	],
	targets: [
		.target(name: "PerfectMustache", dependencies: []),
		.testTarget(name: "PerfectMustacheTests", dependencies: ["PerfectMustache"])
	]
)

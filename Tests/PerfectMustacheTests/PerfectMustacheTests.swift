import XCTest
import PerfectHTTP
import PerfectNet
import PerfectLib
@testable import PerfectMustache

class ShimHTTPRequest: HTTPRequest {
	var method = HTTPMethod.get
	var path = "/"
	var queryParams = [(String, String)]()
	var protocolVersion = (1, 1)
	var remoteAddress = (host: "127.0.0.1", port: 8000 as UInt16)
	var serverAddress = (host: "127.0.0.1", port: 8282 as UInt16)
	var serverName = "my_server"
	var documentRoot = "./webroot"
	var connection = NetTCP()
	var urlVariables = [String:String]()
	func header(_ named: HTTPRequestHeader.Name) -> String? { return nil }
	func addHeader(_ named: HTTPRequestHeader.Name, value: String) {}
	func setHeader(_ named: HTTPRequestHeader.Name, value: String) {}
	var headers = AnyIterator<(HTTPRequestHeader.Name, String)> { return nil }
	var postParams = [(String, String)]()
	var postBodyBytes: [UInt8]? = nil
	var postBodyString: String? = nil
	var postFileUploads: [MimeReader.BodySpec]? = nil
	var scratchPad = [String:Any]()
}

class ShimHTTPResponse: HTTPResponse {
	var request: HTTPRequest = ShimHTTPRequest()
	var status: HTTPResponseStatus = .ok
	var isStreaming = false
	var bodyBytes = [UInt8]()
	func header(_ named: HTTPResponseHeader.Name) -> String? { return nil }
	func addHeader(_ named: HTTPResponseHeader.Name, value: String) -> Self { return self }
	func setHeader(_ named: HTTPResponseHeader.Name, value: String) -> Self { return self }
	var headers = AnyIterator<(HTTPResponseHeader.Name, String)> { return nil }
	func addCookie(_: PerfectHTTP.HTTPCookie) {}
	func appendBody(bytes: [UInt8]) {}
	func appendBody(string: String) {}
	func setBody(json: [String:Any]) throws {}
	func push(callback: @escaping (Bool) -> ()) {}
	func completed() {}
}

class PerfectMustacheTests: XCTestCase {
	
	func testMustacheParser1() {
		let usingTemplate = "TOP {\n{{#name}}\n{{name}}{{/name}}\n}\nBOTTOM"
		do {
			let template = try MustacheParser().parse(string: usingTemplate)
			let d = ["name":"The name"] as [String:Any]
			
			let response = ShimHTTPResponse()
			
			let context = MustacheWebEvaluationContext(webResponse: response, map: d)
			let collector = MustacheEvaluationOutputCollector()
			template.evaluate(context: context, collector: collector)
			
			XCTAssertEqual(collector.asString(), "TOP {\n\nThe name\n}\nBOTTOM")
		} catch {
			XCTAssert(false)
		}
	}
	
	func testMustacheLambda1() {
		let usingTemplate = "TOP {\n{{#name}}\n{{name}}{{/name}}\n}\nBOTTOM"
		do {
			let nameVal = "Me!"
			let template = try MustacheParser().parse(string: usingTemplate)
			let d = ["name":{ (tag:String, context:MustacheEvaluationContext) -> String in return nameVal }] as [String:Any]
			
			let response = ShimHTTPResponse()
			
			let context = MustacheWebEvaluationContext(webResponse: response, map: d)
			let collector = MustacheEvaluationOutputCollector()
			template.evaluate(context: context, collector: collector)
			
			let result = collector.asString()
			XCTAssertEqual(result, "TOP {\n\n\(nameVal)\n}\nBOTTOM")
		} catch {
			XCTAssert(false)
		}
	}
	
	func testMustacheParser2() {
		let usingTemplate = "TOP {\n{{#name}}\n{{name}}{{/name}}\n}\nBOTTOM"
		do {
			let template = try MustacheParser().parse(string: usingTemplate)
			let d = ["name":"The name"] as [String:Any]
			
			let context = MustacheEvaluationContext(map: d)
			let collector = MustacheEvaluationOutputCollector()
			template.evaluate(context: context, collector: collector)
			
			XCTAssertEqual(collector.asString(), "TOP {\n\nThe name\n}\nBOTTOM")
		} catch {
			XCTAssert(false)
		}
	}
	
	func testMustacheParser3() {
		let templateText = "TOP {\n{{#name}}\n{{name}}{{/name}}\n}\nBOTTOM"
		do {
			let d = ["name":"The name"] as [String:Any]
			let context = MustacheEvaluationContext(templateContent: templateText, map: d)
			let collector = MustacheEvaluationOutputCollector()
			let responseString = try context.formulateResponse(withCollector: collector)
			XCTAssertEqual(responseString, "TOP {\n\nThe name\n}\nBOTTOM")
		} catch {
			XCTAssert(false)
		}
	}
	
	func testMustacheLambda2() {
		let usingTemplate = "TOP {\n{{#name}}\n{{name}}{{/name}}\n}\nBOTTOM"
		do {
			let nameVal = "Me!"
			let template = try MustacheParser().parse(string: usingTemplate)
			let d = ["name":{ (tag:String, context:MustacheEvaluationContext) -> String in return nameVal }] as [String:Any]
			
			let context = MustacheEvaluationContext(map: d)
			let collector = MustacheEvaluationOutputCollector()
			template.evaluate(context: context, collector: collector)
			
			let result = collector.asString()
			XCTAssertEqual(result, "TOP {\n\n\(nameVal)\n}\nBOTTOM")
		} catch {
			XCTAssert(false)
		}
	}
	
	func testPartials1() {
		let src = "{{> top }} {\n{{#name}}\n{{name}}{{/name}}\n}\n{{> bottom }}"
		let main = File("./foo.mustache")
		let top = File("./top.mustache")
		let bottom = File("./bottom.mustache")
		let d = ["name":"The name"] as [String:Any]
		
		defer {
			main.delete()
			top.delete()
			bottom.delete()
		}
		do {
			try main.open(.truncate)
			try top.open(.truncate)
			try bottom.open(.truncate)
			
			try main.write(string: src)
			try top.write(string: "TOP")
			try bottom.write(string: "BOTTOM")
			
			main.close()
			top.close()
			bottom.close()
			
			let context = MustacheEvaluationContext(templatePath: "./foo.mustache", map: d)
			let collector = MustacheEvaluationOutputCollector()
			let result = try context.formulateResponse(withCollector: collector)
			XCTAssertEqual(result, "TOP {\n\n\(d["name"]!)\n}\nBOTTOM")
			
		} catch {
			XCTAssert(false, "\(error)")
		}
	}
	
	func testDotNotation1() {
		let usingTemplate = "TOP {\n{{name.first}} {{name.last}}\n}\nBOTTOM"
		do {
			let template = try MustacheParser().parse(string: usingTemplate)
			let d = ["name": ["first": "The", "last": "name"]] as [String:Any]
			
			let response = ShimHTTPResponse()
			
			let context = MustacheWebEvaluationContext(webResponse: response, map: d)
			let collector = MustacheEvaluationOutputCollector()
			template.evaluate(context: context, collector: collector)
			
			XCTAssertEqual(collector.asString(), "TOP {\nThe name\n}\nBOTTOM")
		} catch {
			XCTAssert(false)
		}
	}
	
	func testDotNotation2() {
		let usingTemplate = "TOP {\n{{foo.data.name.first}} {{foo.data.name.last}}\n}\nBOTTOM"
		do {
			let template = try MustacheParser().parse(string: usingTemplate)
			let d = ["foo": ["data": ["name": ["first": "The", "last": "name"]]]] as [String:Any]
			
			let response = ShimHTTPResponse()
			
			let context = MustacheWebEvaluationContext(webResponse: response, map: d)
			let collector = MustacheEvaluationOutputCollector()
			template.evaluate(context: context, collector: collector)
			
			XCTAssertEqual(collector.asString(), "TOP {\nThe name\n}\nBOTTOM")
		} catch {
			XCTAssert(false)
		}
	}

    static var allTests : [(String, (PerfectMustacheTests) -> () throws -> Void)] {
		return [
			("testMustacheParser1", testMustacheParser1),
			("testMustacheLambda1", testMustacheLambda1),
			("testMustacheParser2", testMustacheParser2),
			("testMustacheLambda2", testMustacheLambda2),
			("testPartials1", testPartials1),
			("testDotNotation1", testDotNotation1),
			("testDotNotation2", testDotNotation2)
        ]
    }
}

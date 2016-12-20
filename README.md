# Perfect-Mustache

<p align="center">
    <a href="http://perfect.org/get-involved.html" target="_blank">
        <img src="http://perfect.org/assets/github/perfect_github_2_0_0.jpg" alt="Get Involed with Perfect!" width="854" />
    </a>
</p>

<p align="center">
    <a href="https://github.com/PerfectlySoft/Perfect" target="_blank">
        <img src="http://www.perfect.org/github/Perfect_GH_button_1_Star.jpg" alt="Star Perfect On Github" />
    </a>  
    <a href="http://stackoverflow.com/questions/tagged/perfect" target="_blank">
        <img src="http://www.perfect.org/github/perfect_gh_button_2_SO.jpg" alt="Stack Overflow" />
    </a>  
    <a href="https://twitter.com/perfectlysoft" target="_blank">
        <img src="http://www.perfect.org/github/Perfect_GH_button_3_twit.jpg" alt="Follow Perfect on Twitter" />
    </a>  
    <a href="http://perfect.ly" target="_blank">
        <img src="http://www.perfect.org/github/Perfect_GH_button_4_slack.jpg" alt="Join the Perfect Slack" />
    </a>
</p>

<p align="center">
    <a href="https://developer.apple.com/swift/" target="_blank">
        <img src="https://img.shields.io/badge/Swift-3.0-orange.svg?style=flat" alt="Swift 3.0">
    </a>
    <a href="https://developer.apple.com/swift/" target="_blank">
        <img src="https://img.shields.io/badge/Platforms-OS%20X%20%7C%20Linux%20-lightgray.svg?style=flat" alt="Platforms OS X | Linux">
    </a>
    <a href="http://perfect.org/licensing.html" target="_blank">
        <img src="https://img.shields.io/badge/License-Apache-lightgrey.svg?style=flat" alt="License Apache">
    </a>
    <a href="http://twitter.com/PerfectlySoft" target="_blank">
        <img src="https://img.shields.io/badge/Twitter-@PerfectlySoft-blue.svg?style=flat" alt="PerfectlySoft Twitter">
    </a>
    <a href="http://perfect.ly" target="_blank">
        <img src="http://perfect.ly/badge.svg" alt="Slack Status">
    </a>
</p>

Mustache template support for Perfect.



This package is designed to work along with [Perfect](https://github.com/PerfectlySoft/Perfect). It provides Mustache template support for your server.

## Issues

We are transitioning to using JIRA for all bugs and support related issues, therefore the GitHub issues has been disabled.

If you find a mistake, bug, or any other helpful suggestion you'd like to make on the docs please head over to [http://jira.perfect.org:8080/servicedesk/customer/portal/1](http://jira.perfect.org:8080/servicedesk/customer/portal/1) and raise it.

A comprehensive list of open issues can be found at [http://jira.perfect.org:8080/projects/ISS/issues](http://jira.perfect.org:8080/projects/ISS/issues)

## Quick Start

To start, add this project as a dependency in your Package.swift file.

```swift
.Package(url: "https://github.com/PerfectlySoft/Perfect-Mustache.git", majorVersion: 2, minor: 0)
```

The following snippet illustrates how to use mustache templates in your URL handler. In this example, the template named "test.html" would be located in your server's web root directory.

```swift
{
	request, response in 
	let webRoot = request.documentRoot
	mustacheRequest(request: request, response: response, handler: TestHandler(), templatePath: webRoot + "/test.html")
}
```

The template page handler, which you would impliment, might look like the following.

```swift
struct TestHandler: MustachePageHandler { // all template handlers must inherit from PageHandler
	// This is the function which all handlers must impliment.
	// It is called by the system to allow the handler to return the set of values which will be used when populating the template.
	// - parameter context: The MustacheWebEvaluationContext which provides access to the HTTPRequest containing all the information pertaining to the request
	// - parameter collector: The MustacheEvaluationOutputCollector which can be used to adjust the template output. For example a `defaultEncodingFunc` could be installed to change how outgoing values are encoded.
	func extendValuesForResponse(context contxt: MustacheWebEvaluationContext, collector: MustacheEvaluationOutputCollector) {
		var values = MustacheEvaluationContext.MapType()
		values["value"] = "hello"
		/// etc.
		contxt.extendValues(with: values)
		do {
			try contxt.requestCompleted(withCollector: collector)
		} catch {
			let response = contxt.webResponse
			response.status = .internalServerError
			response.appendBody(string: "\(error)")
			response.completed()
		}
	}
}
```

Look at the [UploadEnumerator](https://github.com/PerfectExamples/Perfect-UploadEnumerator) example for a more concrete example.

**Tag Support**

This mustache template processor supports:

* {{regularTags}}
* {{& unencodedTags}}
* {{# sections}} ... {{/sections}}
* {{^ invertedSections}} ... {{/invertedSections}}
* {{! comments}}
* {{> partials}}
* lambdas

**Partials**

All files used for partials must be located in the same directory as the calling template. Additionally, all partial files *must* have the file extension of **mustache** but this extension must not be included in the partial tag itself. For example, to include the contents of the file *foo.mustache* you would use the tag ```{{> foo }}```.

**Encoding**

By default, all encoded tags (i.e. regular tags) are HTML encoded and &lt; &amp; &gt; entities will be escaped. In your handler you can manually set the ```MustacheEvaluationOutputCollector.defaultEncodingFunc``` function to perform whatever encoding you need. For example when outputting JSON data you would want to set this function to something like the following:

```swift
collector.defaultEncodingFunc = { 
	string in 
	return (try? string.jsonEncodedString()) ?? "bad string"
}
```

**Lambdas**

Functions can be added to the values dictionary. These will be executed and the results will be added to the template output. Such functions should have the following signature:

```swift
(tag: String, context: MustacheEvaluationContext) -> String
```

The ```tag``` parameter will be the tag name. For example the tag {{name}} would give you the value "name" for the tag parameter.

//
//  URLProtocolStub.swift
//  BreedSheet
//
//  Created by Pim on 31/07/2026.
//

import Foundation

/// Generates stubbed responses for testing purposes. Intercepts every request made through the configured
/// `URLSession`, returning a canned response instead of making the actual request.
final class URLProtocolStub: URLProtocol {
	struct Stub {
		let statusCode: Int
		var headers: [String: String] = [:]
		var data: Data = Data()
		var error: Error?
	}

	/// URLSession calls the `URLProtocol` methods on a background queue, so these need to be readable/writable off the
	/// main actor. Tests that use this stub should be configured to run serialized so there's no concurrent-access race
	/// in practice.
	nonisolated(unsafe) static var stub: Stub?
	nonisolated(unsafe) static var lastRequest: URLRequest?

	override class func canInit(with request: URLRequest) -> Bool { true }
	override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

	override func startLoading() {
		Self.lastRequest = request

		guard let stub = Self.stub else {
			client?.urlProtocol(self, didFailWithError: URLError(.unknown))
			return
		}
		if let error = stub.error {
			client?.urlProtocol(self, didFailWithError: error)
			return
		}
		let response = HTTPURLResponse(
			url: request.url!,
			statusCode: stub.statusCode,
			httpVersion: "HTTP/1.1",
			headerFields: stub.headers
		)!
		client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
		client?.urlProtocol(self, didLoad: stub.data)
		client?.urlProtocolDidFinishLoading(self)
	}

	override func stopLoading() {}
}

extension URLProtocolStub {
	static func makeSession() -> URLSession {
		let configuration = URLSessionConfiguration.ephemeral
		configuration.protocolClasses = [URLProtocolStub.self]
		return URLSession(configuration: configuration)
	}
}

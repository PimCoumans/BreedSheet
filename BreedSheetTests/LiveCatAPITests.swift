//
//  LiveCatAPITests.swift
//  BreedSheet
//
//  Created by Pim on 31/07/2026.
//

import Foundation
import Testing
@testable import BreedSheet

/// Explicitly runs each test serialized as properties of `URLProtocolStub` can only be set as static vars.
@Suite(.serialized)
@MainActor
struct LiveCatAPITests {
	let baseURL = URL(string: "https://api.thecatapi.com/v1")!
	let apiKey = "test-api-key"

	func makeClient() -> LiveCatAPI {
		LiveCatAPI(baseURL: baseURL, apiKey: apiKey, urlSession: URLProtocolStub.makeSession())
	}

	@Test func testRequestURLQueryItemsAndAPIKeyHeader() async throws {
		URLProtocolStub.stub = .init(statusCode: 200, data: Data("[]".utf8))
		let client = makeClient()

		_ = try await client.fetchBreeds(page: 2, limit: 5)

		let request = try #require(URLProtocolStub.lastRequest)
		let url = try #require(request.url)
		#expect(url.path == "/v1/breeds")
		#expect(request.value(forHTTPHeaderField: "x-api-key") == apiKey)

		let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
		#expect(queryItems.contains(URLQueryItem(name: "page", value: "2")))
		#expect(queryItems.contains(URLQueryItem(name: "limit", value: "5")))
	}

	@Test func testDecodesBreedsAndHandlesMissingImage() async throws {
		let imageURLString = "https://cdn2.thecatapi.com/images/0XYvRd7oD.jpg"
		let json = """
		[
			{"id": "abys", "name": "Abyssinian", "image": {"url": "\(imageURLString)"}},
			{"id": "nomi", "name": "No Image Cat"}
		]
		"""

		URLProtocolStub.stub = .init(statusCode: 200, data: Data(json.utf8))
		let client = makeClient()

		let breeds = try await client.fetchBreeds(page: 0, limit: 2)

		#expect(breeds.count == 2)
		#expect(breeds[0].image?.url.absoluteString == "https://cdn2.thecatapi.com/images/0XYvRd7oD.jpg")
		#expect(breeds[1].image == nil)
	}

	@Test(arguments: [401, 403, 404, 429, 500])
	func testHTTPErrorStatusCodesMapToHTTPErrorWithDecodedMessage(statusCode: Int) async throws {
		let errorJSON = "{\"message\": \"Something went wrong\"}"
		URLProtocolStub.stub = .init(statusCode: statusCode, data: Data(errorJSON.utf8))
		let client = makeClient()

		do {
			_ = try await client.fetchBreeds(page: 0, limit: 1)
			Issue.record("Expected fetchBreeds to throw .httpError for status \(statusCode)")
		} catch {
			#expect(error == .httpError(statusCode: statusCode, message: "Something went wrong"))
		}
	}

	@Test func testHTTPErrorWithoutBodyStillReportsStatusCode() async throws {
		URLProtocolStub.stub = .init(statusCode: 500, data: Data())
		let client = makeClient()

		do {
			_ = try await client.fetchBreeds(page: 0, limit: 1)
			Issue.record("Expected fetchBreeds to throw .httpError for status \(500)")
		} catch {
			#expect(error == .httpError(statusCode: 500, message: nil))
		}
	}

	@Test func testMalformedJSONMapsToDecodingError() async throws {
		URLProtocolStub.stub = .init(statusCode: 200, data: Data("bad json".utf8))
		let client = makeClient()

		do {
			_ = try await client.fetchBreeds(page: 0, limit: 1)
			Issue.record("Expected fetchBreeds to throw .decodingError")
		} catch {
			guard case .decodingError = error else {
				Issue.record("Expected .decodingError, got \(error)")
				return
			}
		}
	}

	@Test func testTransportFailureMapsToTransportError() async throws {
		URLProtocolStub.stub = .init(statusCode: 200, error: URLError(.notConnectedToInternet))
		let client = makeClient()

		do {
			_ = try await client.fetchBreeds(page: 0, limit: 1)
			Issue.record("Expected fetchBreeds to throw .transportError")
		} catch {
			guard case .transportError = error else {
				Issue.record("Expected .transportError, got \(error)")
				return
			}
		}
	}
}

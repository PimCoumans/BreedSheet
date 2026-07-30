//
//  LiveCatAPI.swift
//  BreedSheet
//
//  Created by Pim on 28/07/2026.
//

import Foundation

struct LiveCatAPI: CatAPI {
	private let baseURL: URL
	private let apiKey: String

	private let urlSession: URLSession
	private let jsonDecoder = JSONDecoder()

	init(baseURL: URL, apiKey: String, urlSession: URLSession = .shared) {
		self.baseURL = baseURL
		self.apiKey = apiKey
		self.urlSession = urlSession
		jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
	}

	func fetchBreeds(page: Int = 0, limit: Int = 12) async throws(CatAPIError) -> [Breed] {
		let queryItems = [
			URLQueryItem(name: "page", value: "\(page)"),
			URLQueryItem(name: "limit", value: "\(limit)")
		]
		return try await performRequest(for: "breeds", queryItems: queryItems)
	}
}

extension LiveCatAPI {
	enum HTTPMethod: String {
		case GET = "GET"
		case POST = "POST"
	}

	private func performRequest<Response: Decodable>(
		for path: String, method: HTTPMethod = .GET, queryItems: [URLQueryItem] = []
	) async throws(CatAPIError) -> Response {
		let url = baseURL.appending(path: path).appending(queryItems: queryItems)
		var request = URLRequest(url: url)
		request.httpMethod = method.rawValue
		request.addValue(apiKey, forHTTPHeaderField: "x-api-key")

		let data: Data
		let response: URLResponse

		// Wrapped thrown errors in CatAPIError
		do {
			(data, response) = try await urlSession.data(for: request)
		} catch {
			throw .serverError(underlyingError: error)
		}

		guard let httpResponse = response as? HTTPURLResponse else {
			throw .serverError(underlyingError: URLError(.badServerResponse))
		}

		guard (200...299).contains(httpResponse.statusCode) else {
			throw .responseError(statusCode: httpResponse.statusCode)
		}

		do {
			return try jsonDecoder.decode(Response.self, from: data)
		} catch {
			throw .jsonError(underlyingError: error)
		}
	}
}

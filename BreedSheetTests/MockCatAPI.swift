//
//  MockCatAPI.swift
//  BreedSheet
//
//  Created by Pim on 31/07/2026.
//

import Foundation
@testable import BreedSheet

/// A configurable `CatAPI` mock
final class MockCatAPI: CatAPI {
	private(set) var receivedRequests: [(page: Int, limit: Int)] = []
	var responseDelay: TimeInterval

	/// Uses non-typed throws due to Swift inconsistency with closures with typed throws in initializer
	/// Thrown errors are casted as `CatAPIError` when handled.
	var handler: (_ page: Int, _ limit: Int) throws -> [Breed]

	init(
		responseDelay: TimeInterval = 0,
		handler: @escaping (_ page: Int, _ limit: Int) throws -> [Breed]
	) {
		self.responseDelay = responseDelay
		self.handler = handler
	}

	func fetchBreeds(page: Int, limit: Int) async throws(CatAPIError) -> [Breed] {
		receivedRequests.append((page, limit))
		if responseDelay > 0 {
			try? await Task.sleep(for: .seconds(responseDelay))
		}
		do {
			return try handler(page, limit)
		} catch let error as CatAPIError {
			throw error
		} catch {
			throw .transportError(underlyingError: error)
		}
	}
}

extension MockCatAPI {
	/// Always returns the same breeds, regardless of page.
	static func constant(_ breeds: [Breed], responseDelay: TimeInterval = 0) -> MockCatAPI {
		MockCatAPI(responseDelay: responseDelay) { _, _ in breeds }
	}

	/// Always fails with the provided error.
	static func failing(with error: CatAPIError, responseDelay: TimeInterval = 0) -> MockCatAPI {
		MockCatAPI(responseDelay: responseDelay) { _, _ in throw error }
	}

	/// Returns `pages[page]` for each requested page, or an empty array once `page` is past the end of `pages`,
	/// like a paginated API signals "no more content".
	static func paged(_ pages: [[Breed]], responseDelay: TimeInterval = 0) -> MockCatAPI {
		MockCatAPI(responseDelay: responseDelay) { page, _ in
			guard pages.indices.contains(page) else {
				return []
			}
			return pages[page]
		}
	}
}

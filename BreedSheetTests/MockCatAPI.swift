//
//  MockCatAPI.swift
//  BreedSheet
//
//  Created by Pim on 28/07/2026.
//

import Foundation
@testable import BreedSheet

struct MockCatAPI: CatAPI {

	let shouldFail: Bool
	let responseDelay: TimeInterval
	let breeds: [Breed]

	init(shouldFail: Bool, responseDelay: TimeInterval = 0, breeds: [Breed] = []) {
		self.shouldFail = shouldFail
		self.responseDelay = responseDelay
		self.breeds = breeds
	}

	func fetchBreeds(page: Int, limit: Int) async throws(CatAPIError) -> [Breed] {
		if responseDelay > 0 {
			try? await Task.sleep(for: .seconds(responseDelay)) // Catching `CancellationError` out of scope for now
		}
		if shouldFail {
			throw .serverError(underlyingError: URLError(.cannotConnectToHost))
		}
		return breeds
	}
}

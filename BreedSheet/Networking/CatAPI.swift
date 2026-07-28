//
//  CatAPI.swift
//  BreedSheet
//
//  Created by Pim on 28/07/2026.
//

import Foundation

enum CatAPIError: Error {
	// Ideally these errors are less generic and tell more about the underlying error
	case serverError(underlyingError: Error)
	case responseError(statusCode: Int)
	case jsonError(underlyingError: Error)
}

protocol CatAPI {
	func fetchBreeds(page: Int, limit: Int) async throws(CatAPIError) -> [Breed]
}

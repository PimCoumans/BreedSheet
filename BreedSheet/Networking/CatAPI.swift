//
//  CatAPI.swift
//  BreedSheet
//
//  Created by Pim on 28/07/2026.
//

import Foundation

enum CatAPIError: Error, LocalizedError, Equatable {
	/// The request never reached a server (offline, timed out, DNS failure, cancelled, etc).
	case transportError(underlyingError: Error)
	/// A server response was received but its status code was outside 200...299.
	case httpError(statusCode: Int, message: String?)
	/// The response body could not be decoded into the expected type.
	case decodingError(underlyingError: Error)

	var errorDescription: String? {
		switch self {
		case .transportError(let underlyingError):
			"Couldn't reach The Cat API: \(underlyingError.localizedDescription)"
		case .httpError(let statusCode, let message):
			if let message {
				"The Cat API returned an error (HTTP \(statusCode)): \(message)"
			} else {
				"The Cat API returned an unexpected status code: \(statusCode)"
			}
		case .decodingError(let underlyingError):
			"Couldn't understand The Cat API's response: \(underlyingError.localizedDescription)"
		}
	}

	// `Error` isn't `Equatable`, so underlying errors are compared by their description.
	// Good enough to let tests assert which case/HTTP status/message occurred without
	// needing to match the exact underlying `URLError`/`DecodingError` instance.
	static func == (lhs: CatAPIError, rhs: CatAPIError) -> Bool {
		switch (lhs, rhs) {
		case (.transportError(let lhsError), .transportError(let rhsError)):
			lhsError.localizedDescription == rhsError.localizedDescription
		case (.httpError(let lhsStatus, let lhsMessage), .httpError(let rhsStatus, let rhsMessage)):
			lhsStatus == rhsStatus && lhsMessage == rhsMessage
		case (.decodingError(let lhsError), .decodingError(let rhsError)):
			lhsError.localizedDescription == rhsError.localizedDescription
		default:
			false
		}
	}
}

protocol CatAPI {
	func fetchBreeds(page: Int, limit: Int) async throws(CatAPIError) -> [Breed]
}

//
//  PreviewCatAPI.swift
//  BreedSheet
//
//  Created by Pim on 31/07/2026.
//

#if DEBUG
import Foundation

/// An in-memory `CatAPI` used for both SwiftUI `#Preview`s and `BreedSheetUITests` using `uiTestScenario`
final class PreviewCatAPI: CatAPI {
	enum Scenario {
		case success(breeds: [Breed])
		case empty
		case failure(CatAPIError)
		/// Fails on the first request, then succeeds with provided `breeds` on every subsequent request
		case recoverAfterFailure(breeds: [Breed])
	}

	private let scenario: Scenario
	private let responseDelay: TimeInterval
	private var hasFailedOnce = false

	init(scenario: Scenario, responseDelay: TimeInterval = 1) {
		self.scenario = scenario
		self.responseDelay = responseDelay
	}

	func fetchBreeds(page: Int, limit: Int) async throws(CatAPIError) -> [Breed] {
		if responseDelay > 0 {
			try? await Task.sleep(for: .seconds(responseDelay))
		}
		switch scenario {
		case .success(let breeds):
			return page == 0 ? breeds : []
		case .empty:
			return []
		case .failure(let error):
			throw error
		case .recoverAfterFailure(let breeds):
			guard hasFailedOnce else {
				hasFailedOnce = true
				throw .httpError(statusCode: 500, message: "Temporary failure, please retry")
			}
			return page == 0 ? breeds : []
		}
	}
}

extension PreviewCatAPI {
	static let sampleBreeds = [
		Breed(
			id: "abys",
			name: "Abyssinian",
			origin: "Ethiopia",
			temperament: "Active, Energetic, Independent, Intelligent, Gentle",
			lifeSpan: "9 - 15",
			image: .init(url: URL(string: "https://cdn2.thecatapi.com/images/0XYvRd7oD.jpg")!)
		),
		Breed(
			id: "aege",
			name: "Aegean",
			origin: "Greece",
			temperament: "Affectionate, Social, Intelligent, Playful, Active",
			lifeSpan: "9 - 12",
			image: .init(url: URL(string: "https://cdn2.thecatapi.com/images/ozEvzdVM-.jpg")!)
		)
	]

	/// Launch environment key used to se to specific scenario
	private static let uiTestScenarioEnvironmentKey = "UITEST_SCENARIO"

	/// Non-nil when the app was launched and configured to run a specific mocked scenario
	static var uiTestScenario: PreviewCatAPI? {
		guard let rawValue = ProcessInfo.processInfo.environment[uiTestScenarioEnvironmentKey] else {
			return nil
		}
		switch rawValue {
		case "success":
			return PreviewCatAPI(scenario: .success(breeds: sampleBreeds), responseDelay: 0)
		case "empty":
			return PreviewCatAPI(scenario: .empty, responseDelay: 0)
		case "failure":
			return PreviewCatAPI(scenario: .failure(.httpError(statusCode: 403, message: "Invalid API key")), responseDelay: 0)
		case "recoverAfterFailure":
			return PreviewCatAPI(scenario: .recoverAfterFailure(breeds: sampleBreeds), responseDelay: 0)
		default:
			return nil
		}
	}
}
#endif

//
//  BreedsViewModel.swift
//  BreedSheet
//
//  Created by Pim on 28/07/2026.
//

import Observation

@Observable
class BreedsViewModel {
	enum State {
		case idle
		case loading
		case loaded
		case failed(CatAPIError)
	}

	var breads: [Breed] = []
	var state: State = .idle

	@ObservationIgnored
	private let apiClient: any CatAPI

	init(apiClient: any CatAPI) {
		self.apiClient = apiClient
	}

	func loadBreeds() async {
		state = .loading
		do {
			breads = try await apiClient.fetchBreeds(page: 0, limit: 12)
			state = .loaded
		} catch {
			state = .failed(error)
		}
	}
}

extension BreedsViewModel.State: Equatable {
	// Custom Equatable conformance, making it easier to compare states
	static func == (lhs: BreedsViewModel.State, rhs: BreedsViewModel.State) -> Bool {
		switch (lhs, rhs) {
		case (.idle, .idle): true
		case (.loading, .loading): true
		case (.loaded, .loaded): true
		case (.failed(let lhsError), .failed(let rhsError)):
			true // For sake of simplicity/brevity, not comparing server errors here
		default: false
		}
	}
}

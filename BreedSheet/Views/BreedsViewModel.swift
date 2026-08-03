//
//  BreedsViewModel.swift
//  BreedSheet
//
//  Created by Pim on 28/07/2026.
//

import Observation

@Observable
class BreedsViewModel {
	enum State: Equatable {
		case idle
		case loading
		case loaded
		case failed(CatAPIError)
	}

	var breeds: [Breed] = []
	var state: State = .idle

	var hasMoreContent: Bool = true
	private var page: Int = 0
	private let pageLimit: Int = 12

	@ObservationIgnored
	private let apiClient: any CatAPI

	init(apiClient: any CatAPI) {
		self.apiClient = apiClient
	}

	func reload() async {
		page = 0
		await loadNextPage()
	}

	func loadNextPageIfPossible() async {
		guard hasMoreContent else {
			return
		}
		await loadNextPage()
	}

	func loadNextPage() async {
		guard state != .loading else {
			return
		}
		state = .loading
		do {
			let nextPage = try await apiClient.fetchBreeds(page: page, limit: pageLimit)
			if page == 0 {
				breeds = nextPage
			} else {
				breeds.append(contentsOf: nextPage)
			}
			page += 1
			hasMoreContent = nextPage.isEmpty == false
			state = .loaded
		} catch {
			state = .failed(error)
		}
	}
}

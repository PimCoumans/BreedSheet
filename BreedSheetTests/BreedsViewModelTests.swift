//
//  BreedsViewModelTests.swift
//  BreedSheet
//
//  Created by Pim on 28/07/2026.
//

import Foundation
import Testing
@testable import BreedSheet

@MainActor
struct BreedsViewModelTests {
	@Test func testSuccessfulLoad() async throws {
		let fakeImageURL = URL(string: "https://dawn.tech/assets/img/logo-light.svg")!
		let mockClient = MockCatAPI(
			shouldFail: false,
			responseDelay: 0,
			breeds: [
				Breed(id: "1", name: "European Shorthair", image: Breed.BreedImage(url: fakeImageURL)),
				Breed(id: "2", name: "Russian Blue", image: Breed.BreedImage(url: fakeImageURL))
			])

		let viewModel = BreedsViewModel(apiClient: mockClient)
		#expect(viewModel.state == .idle)

		await viewModel.loadBreeds()

		#expect(viewModel.state == .loaded)
		#expect(viewModel.breads.count == 2)
		#expect(viewModel.breads.first?.name == "European Shorthair")
	}

	@Test func testFailedLoad() async throws {
		let mockClient = MockCatAPI(shouldFail: true)

		let viewModel = BreedsViewModel(apiClient: mockClient)
		await viewModel.loadBreeds()

		#expect(viewModel.breads.isEmpty)

		guard case .failed = viewModel.state else {
			Issue.record("Expected viewModel state to be `.failed`", severity: .error)
			return
		}
	}
}

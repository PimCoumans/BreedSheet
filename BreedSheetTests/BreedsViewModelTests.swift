//
//  BreedsViewModelTests.swift
//  BreedSheet
//
//  Created by Pim on 31/07/2026.
//

import Foundation
import Testing
@testable import BreedSheet

@MainActor
struct BreedsViewModelTests {

	@Test func testInitialStateIsIdle() {
		let viewModel = BreedsViewModel(apiClient: MockCatAPI.constant([]))
		#expect(viewModel.state == .idle)
		#expect(viewModel.breeds.isEmpty)
	}

	@Test func testSuccessfulLoad() async throws {
		let mockClient = MockCatAPI.constant([
			breed("1", "European Shorthair"),
			breed("2", "Russian Blue")
		])
		let viewModel = BreedsViewModel(apiClient: mockClient)

		await viewModel.loadNextPage()

		#expect(viewModel.state == .loaded)
		#expect(viewModel.breeds.count == 2)
		#expect(viewModel.breeds.first?.name == "European Shorthair")
	}

	@Test func testFailedLoad() async throws {
		let apiError: CatAPIError = .transportError(underlyingError: URLError(.notConnectedToInternet))
		let mockClient = MockCatAPI.failing(with: apiError)
		let viewModel = BreedsViewModel(apiClient: mockClient)

		await viewModel.loadNextPage()

		#expect(viewModel.breeds.isEmpty)
		#expect(viewModel.state == .failed(apiError))
	}

	@Test func testSpecificHTTPErrorSurfacesInFailedState() async throws {
		let apiError: CatAPIError = .httpError(statusCode: 403, message: "Invalid API key")
		let mockClient = MockCatAPI.failing(with: apiError)
		let viewModel = BreedsViewModel(apiClient: mockClient)

		await viewModel.loadNextPage()

		#expect(viewModel.state == .failed(apiError))
	}

	@Test func testEmptyResponseResultsInLoadedEmptyState() async throws {
		let viewModel = BreedsViewModel(apiClient: MockCatAPI.constant([]))

		await viewModel.loadNextPage()

		#expect(viewModel.state == .loaded)
		#expect(viewModel.breeds.isEmpty)
		#expect(viewModel.hasMoreContent == false)
	}

	@Test func testPaginationAppendsAcrossPages() async throws {
		let mockClient = MockCatAPI.paged([
			[
				breed("1", "Abyssinian"),
				breed("2", "Aegean")
			],
			[
				breed("3", "Bengal")
			]
		])
		let viewModel = BreedsViewModel(apiClient: mockClient)

		await viewModel.loadNextPage()
		await viewModel.loadNextPageIfPossible()

		#expect(viewModel.breeds.map(\.id) == ["1", "2", "3"])
		#expect(mockClient.receivedRequests.map(\.page) == [0, 1])
	}

	@Test func testHasMoreContentBecomesFalseOnEmptyPage() async throws {
		let mockClient = MockCatAPI.paged([[breed("1", "Abyssinian")]])
		let viewModel = BreedsViewModel(apiClient: mockClient)

		await viewModel.loadNextPage()
		#expect(viewModel.hasMoreContent == true)

		await viewModel.loadNextPageIfPossible()
		#expect(viewModel.hasMoreContent == false)
		#expect(viewModel.breeds.count == 1)
	}

	@Test func testLoadNextPageIfPossiblePerformsNoRequests() async throws {
		let mockClient = MockCatAPI.paged([[breed("1", "Abyssinian")]])
		let viewModel = BreedsViewModel(apiClient: mockClient)

		await viewModel.loadNextPage()
		await viewModel.loadNextPageIfPossible()
		#expect(viewModel.hasMoreContent == false)

		await viewModel.loadNextPageIfPossible()

		#expect(mockClient.receivedRequests.count == 2, "A third request should not be made when no more content is available")
	}

	@Test func testConcurrentLoadsAreCoalesced() async throws {
		let mockClient = MockCatAPI.constant([breed("1", "Abyssinian")], responseDelay: 0.2)
		let viewModel = BreedsViewModel(apiClient: mockClient)

		// Perform two requests in parallel
		async let first: () = viewModel.loadNextPage()
		async let second: () = viewModel.loadNextPage()
		_ = await (first, second)

		#expect(mockClient.receivedRequests.count == 1, "A load already in progress should not trigger a second request")
	}

	@Test func testReloadResetsPageAndReplacesBreeds() async throws {
		let mockClient = MockCatAPI.paged([
			[breed("1", "Abyssinian")],
			[breed("2", "Aegean")]
		])
		let viewModel = BreedsViewModel(apiClient: mockClient)

		await viewModel.loadNextPage()
		await viewModel.loadNextPageIfPossible()
		#expect(viewModel.breeds.map(\.id) == ["1", "2"])

		await viewModel.reload()

		#expect(viewModel.breeds.map(\.id) == ["1"], "reload() should replace, not append the current breeds")
		#expect(mockClient.receivedRequests.map(\.page) == [0, 1, 0])
	}
}

extension BreedsViewModelTests {
	private func breed(_ id: String, _ name: String) -> Breed {
		Breed(id: id, name: name, image: nil)
	}
}

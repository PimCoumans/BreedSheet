//
//  LiveAPITests.swift
//  BreedSheet
//
//  Created by Pim on 28/07/2026.
//

import Testing
@testable import BreedSheet

@MainActor
struct LiveAPITests {
	let client = LiveCatAPI()

	@Test func testBreedsRequest() async throws {
		let breeds = try await client.fetchBreeds()
		#expect(breeds.isEmpty == false, "GetBreeds request should return multiple breeds")
	}

	@Test func testPageLimit() async throws {
		let pageLimit = 6
		let breeds = try await client.fetchBreeds(limit: pageLimit)
		#expect(breeds.count == pageLimit, "GetBreeds request should respect provided page limit")
	}

	@Test func testPagination() async throws {
		let firstPage = try await client.fetchBreeds()
		let secondPage = try await client.fetchBreeds(page: 1)

		let firstPageIdentifiers = Set(firstPage.map(\.id))
		let secondPageIdentifiers = Set(secondPage.map(\.id))

		let overlap = secondPageIdentifiers.intersection(firstPageIdentifiers)
		#expect(
			overlap.isEmpty == true,
			"GetBreeds request pagination should not overlap, but first and second page have \(overlap.count) breeds in common"
		)
	}
}

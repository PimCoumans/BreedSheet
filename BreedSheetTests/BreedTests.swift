//
//  BreedTests.swift
//  BreedSheet
//
//  Created by Pim on 03/08/2026.
//

import Testing
@testable import BreedSheet

struct BreedTests {
	private func breed(temperament: String?) -> Breed {
		Breed(id: "1", name: "Test", temperament: temperament, image: nil)
	}

	@Test func testTemperamentTagsSplitsAndTrimsCommaSeparatedString() {
		let tags = breed(temperament: "Affectionate, Dependent,  Gentle ,Intelligent ").temperamentTags
		#expect(tags == ["Affectionate", "Dependent", "Gentle", "Intelligent"])
	}

	@Test func testTemperamentTagsIsEmptyWhenNil() {
		#expect(breed(temperament: nil).temperamentTags.isEmpty)
	}

	@Test func testTemperamentTagsIgnoresEmptyEntries() {
		let tags = breed(temperament: "Affectionate,, Gentle").temperamentTags
		#expect(tags == ["Affectionate", "Gentle"])
	}
}

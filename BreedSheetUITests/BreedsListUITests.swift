//
//  BreedsListUITests.swift
//  BreedSheetUITests
//
//  Created by Pim on 31/07/2026.
//

import XCTest

final class BreedsListUITests: XCTestCase {

	override func setUpWithError() throws {
		continueAfterFailure = false
	}

	/// Launches the app with `PreviewCatAPI.uiTestScenario` (see `Testing/PreviewCatAPI.swift`)
	/// substituted for the real network client, so these tests are deterministic and need no network access.
	private func launchApp(scenario: String) -> XCUIApplication {
		let app = XCUIApplication()
		app.launchEnvironment["UITEST_SCENARIO"] = scenario
		app.launch()
		return app
	}

	@MainActor
	func testSuccessStateShowsBreedList() throws {
		let app = launchApp(scenario: "success")

		XCTAssertTrue(app.descendants(matching: .any)["breedsList"].waitForExistence(timeout: 5))
		XCTAssertTrue(app.staticTexts["Abyssinian"].waitForExistence(timeout: 5))
		XCTAssertTrue(app.staticTexts["Aegean"].exists)
	}

	@MainActor
	func testEmptyStateShowsMessage() throws {
		let app = launchApp(scenario: "empty")

		XCTAssertTrue(app.staticTexts["No breeds found"].waitForExistence(timeout: 5))
	}

	@MainActor
	func testFailureStateShowsErrorAndRetryButton() throws {
		let app = launchApp(scenario: "failure")

		let retryButton = app.buttons["Retry"]
		XCTAssertTrue(retryButton.waitForExistence(timeout: 5))

		let errorMessage = app.staticTexts.matching(
			NSPredicate(format: "label CONTAINS[c] %@", "Invalid API key")
		).firstMatch
		XCTAssertTrue(errorMessage.exists, "Expected the detailed error message to be shown, not a generic one")
	}

	@MainActor
	func testRetryRecoversFromFailure() throws {
		let app = launchApp(scenario: "recoverAfterFailure")

		let retryButton = app.buttons["Retry"]
		XCTAssertTrue(retryButton.waitForExistence(timeout: 5))

		retryButton.tap()

		XCTAssertTrue(app.staticTexts["Abyssinian"].waitForExistence(timeout: 5))
		XCTAssertFalse(retryButton.exists)
	}
}

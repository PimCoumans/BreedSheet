//
//  BreedSheetApp.swift
//  BreedSheet
//
//  Created by Pim on 28/07/2026.
//

import SwiftUI

@main
struct BreedSheetApp: App {

	@State private var breedsViewModel = BreedsViewModel(apiClient: Self.makeAPIClient())

	var body: some Scene {
		WindowGroup {
			NavigationStack {
				BreedsListView(viewModel: breedsViewModel)
			}
		}
	}

	private static func makeAPIClient() -> any CatAPI {
		do {
			return try LiveCatAPI(baseURL: AppSecrets.catAPIBaseURL(), apiKey: AppSecrets.catAPIKey())
		} catch {
			// A missing/invalid Secrets.xcconfig is a developer-time setup error, so purposefully crash the app
			fatalError(error.localizedDescription)
		}
	}
}

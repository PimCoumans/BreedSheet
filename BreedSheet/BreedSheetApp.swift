//
//  BreedSheetApp.swift
//  BreedSheet
//
//  Created by Pim on 28/07/2026.
//

import SwiftUI

@main
struct BreedSheetApp: App {
	var body: some Scene {
		WindowGroup {
			let api = LiveCatAPI()
			let viewModel = BreedsViewModel(apiClient: api)
			NavigationStack {
				BreedsListView(viewModel: viewModel)
			}
		}
	}
}

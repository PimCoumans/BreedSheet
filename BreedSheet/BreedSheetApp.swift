//
//  BreedSheetApp.swift
//  BreedSheet
//
//  Created by Pim on 28/07/2026.
//

import SwiftUI

@main
struct BreedSheetApp: App {

	@State private var breedsViewModel = BreedsViewModel(apiClient: LiveCatAPI())

	var body: some Scene {
		WindowGroup {
			NavigationStack {
				BreedsListView(viewModel: breedsViewModel)
			}
		}
	}
}

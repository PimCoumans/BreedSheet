//
//  BreedsListView.swift
//  BreedSheet
//
//  Created by Pim on 28/07/2026.
//

import SwiftUI

struct BreedsListView: View {

	@Bindable var viewModel: BreedsViewModel

	var body: some View {
		List(viewModel.breads) { breed in
			BreedListItemView(breed: breed)
		}
		.task {
			await viewModel.loadBreeds()
		}
		.overlay(content: overlayContent)
	}
}

extension BreedsListView {
	private func overlayContent() -> some View {
		Group {
			switch viewModel.state {
			case .loading: ProgressView()
			case .failed(let error): errorView(error)
			case .loaded where viewModel.breads.isEmpty:
				emptyStateView
			default: EmptyView()
			}
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
	}

	private var emptyStateView: some View {
		Text("No breeds found")
			.foregroundColor(.secondary)
	}

	private func errorView(_ error: Error) -> some View {
		// Ignore provided error for now
		VStack(spacing: 12) {
			Image(systemName: "exclamationmark.triangle")
				.font(.title2)
				.foregroundColor(.orange)
			Text("Failed to load breeds")
			Button("Retry") {
				Task { await viewModel.loadBreeds() }
			}
		}
	}
}

#if DEBUG
struct PreviewCatAPI: CatAPI {
	let breeds: [Breed]
	func fetchBreeds(page: Int, limit: Int) async throws(CatAPIError) -> [Breed] {
		breeds
	}
}

#Preview {
	let sampleBreeds = [
		Breed(id: "abys", name: "Abyssinian", image: .init(url: URL(string: "https://cdn2.thecatapi.com/images/0XYvRd7oD.jpg")!)),
		Breed(id: "aege", name: "Aegean", image: .init(url: URL(string: "https://cdn2.thecatapi.com/images/ozEvzdVM-.jpg")!))
	]
	let viewModel = BreedsViewModel(apiClient: PreviewCatAPI(breeds: sampleBreeds))
	BreedsListView(viewModel: viewModel)
}
#endif

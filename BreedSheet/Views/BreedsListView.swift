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
		List {
			ForEach(viewModel.breeds) { breed in
				BreedListItemView(breed: breed)
					.onAppear {
						guard breed == viewModel.breeds.last else {
							return
						}
						Task {
							await viewModel.loadNextPageIfPossible()
						}
					}
			}
			paginationView()
		}
		.accessibilityIdentifier("breedsList")
		.navigationTitle("Cat Breeds")
		.refreshable {
			await viewModel.reload()
		}
		.task {
			await viewModel.loadNextPage()
		}
		.overlay(content: overlayContent)
	}
}

extension BreedsListView {
	private func overlayContent() -> some View {
		Group {
			switch viewModel.state {
			case .failed(let error): errorView(error)
			case .loaded where viewModel.breeds.isEmpty: emptyStateView
			default: EmptyView()
			}
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
	}

	private var emptyStateView: some View {
		Text("No breeds found")
			.foregroundColor(.secondary)
	}

	private func errorView(_ error: CatAPIError) -> some View {
		VStack(spacing: 12) {
			Image(systemName: "exclamationmark.triangle")
				.font(.title2)
				.foregroundColor(.orange)
			Text(error.localizedDescription)
				.multilineTextAlignment(.center)
				.padding(.horizontal)
			Button("Retry") {
				Task { await viewModel.reload() }
			}
		}
	}

	@ViewBuilder
	private func paginationView() -> some View {
		if viewModel.state == .loading {
			ProgressView()
				.frame(maxWidth: .infinity)
				.accessibilityIdentifier("loadingIndicator")
		}
	}
}

#if DEBUG
struct PreviewCatAPI: CatAPI {
	let shouldFail: Bool
	let breeds: [Breed]
	func fetchBreeds(page: Int, limit: Int) async throws(CatAPIError) -> [Breed] {
		try? await Task.sleep(for: .seconds(1))
		if shouldFail {
			throw .responseError(statusCode: 403)
		} else {
			return breeds
		}
	}
}

#Preview("Success") {
	let sampleBreeds = [
		Breed(id: "abys", name: "Abyssinian", image: .init(url: URL(string: "https://cdn2.thecatapi.com/images/0XYvRd7oD.jpg")!)),
		Breed(id: "aege", name: "Aegean", image: .init(url: URL(string: "https://cdn2.thecatapi.com/images/ozEvzdVM-.jpg")!))
	]
	let viewModel = BreedsViewModel(apiClient: PreviewCatAPI(shouldFail: false, breeds: sampleBreeds))
	BreedsListView(viewModel: viewModel)
}

#Preview("Failed") {
	let viewModel = BreedsViewModel(apiClient: PreviewCatAPI(shouldFail: true, breeds: []))
	BreedsListView(viewModel: viewModel)
}

#Preview("Empty") {
	let viewModel = BreedsViewModel(apiClient: PreviewCatAPI(shouldFail: false, breeds: []))
	BreedsListView(viewModel: viewModel)
}
#endif

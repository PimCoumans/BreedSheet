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
			HStack(spacing: 16) {
				AsyncImage(url: breed.image.url) { phase in
					switch phase {
					case .failure:
						Image(systemName: "questionmark.circle")
							.foregroundStyle(Color.secondary)
					case .success(let image):
						image.resizable().aspectRatio(contentMode: .fill).frame(width: 60, height: 60)
					case .empty:
						Color.secondary
					@unknown default:
						EmptyView()
					}
				}
				.frame(width: 60, height: 60)
				.clipShape(RoundedRectangle(cornerRadius: 8))

				Text(breed.name)
					.font(.headline)
					.lineLimit(2)
			}
		}
		.listStyle(.plain)
		.task {
			await viewModel.loadBreeds()
		}
		.overlay {
			switch viewModel.state {
			case .loading:
				ProgressView()
			case .failed:
				ContentUnavailableView("Failed to load breeds", systemImage: "exclamationmark.triangle")
			default:
				EmptyView()
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

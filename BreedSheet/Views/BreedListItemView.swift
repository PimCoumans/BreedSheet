//
//  BreedListItemView.swift
//  BreedSheet
//
//  Created by Pim on 28/07/2026.
//

import SwiftUI

struct BreedListItemView: View {
	var breed: Breed
	
	var body: some View {
		HStack(spacing: 16) {
			AsyncImage(url: breed.image?.url) { phase in
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
}


#Preview {
	List([Breed(id: "abys", name: "Abyssinian", image: .init(url: URL(string: "https://cdn2.thecatapi.com/images/0XYvRd7oD.jpg")!))]) {
		BreedListItemView(breed: $0)
	}
}

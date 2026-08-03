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
		HStack(alignment: .top, spacing: 16) {
			AsyncImage(
				url: breed.image?.url,
				transaction: Transaction(animation: .easeOut.speed(2))
			) { phase in
				switch phase {
				case .failure:
					Image(systemName: "questionmark.circle")
						.foregroundStyle(Color.secondary)
				case .success(let image):
					image
						.resizable()
						.aspectRatio(contentMode: .fill)
						.frame(width: 60, height: 60)
				case .empty:
					Color.gray.opacity(0.5)
				@unknown default:
					EmptyView()
				}
			}
			.frame(width: 60, height: 60)
			.clipShape(RoundedRectangle(cornerRadius: 8))

			VStack(alignment: .leading, spacing: 4) {
				Text(breed.name)
					.font(.headline)
					.lineLimit(2)

				if let subtitle {
					Text(subtitle)
						.font(.subheadline)
						.foregroundStyle(.secondary)
				}

				if breed.temperamentTags.isEmpty == false {
					HStack(spacing: 6) {
						ForEach(breed.temperamentTags.prefix(3), id: \.self) { tag in
							Text(tag)
								.font(.caption2.weight(.medium))
								.padding(.horizontal, 8)
								.padding(.vertical, 3)
								.foregroundStyle(Color.accentColor)
								.background(Color.accentColor.tertiary, in: .capsule)
						}
					}
					.padding(.top, 2)
				}
			}
		}
		.padding(.vertical, 4)
	}

	/// Origin and life span combined into a single compact line, e.g. "Ethiopia, 9 - 15 yrs".
	private var subtitle: String? {
		let lifeSpanText = breed.lifeSpan.map { "\($0) yrs" }
		let parts = [breed.origin, lifeSpanText].compactMap { $0 }
		return parts.isEmpty ? nil : parts.joined(separator: ", ")
	}
}

#Preview {
	List([
		Breed(
			id: "abys",
			name: "Abyssinian",
			origin: "Ethiopia",
			temperament: "Active, Energetic, Independent, Intelligent, Gentle",
			lifeSpan: "9 - 15",
			image: .init(url: URL(string: "https://cdn2.thecatapi.com/images/0XYvRd7oD.jpg")!)
		),
		Breed(id: "none", name: "Missing Extra Data", image: nil)
	]) {
		BreedListItemView(breed: $0)
	}
}

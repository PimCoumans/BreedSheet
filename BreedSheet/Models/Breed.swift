//
//  Breed.swift
//  BreedSheet
//
//  Created by Pim on 28/07/2026.
//

import Foundation

struct Breed: nonisolated Decodable, Identifiable, Equatable {
	struct BreedImage: nonisolated Decodable, Equatable {
		let url: URL
	}

	let id: String
	let name: String
	let origin: String?
	let temperament: String?
	let lifeSpan: String?

	let image: BreedImage?

	init(
		id: String,
		name: String,
		origin: String? = nil,
		temperament: String? = nil,
		lifeSpan: String? = nil,
		image: BreedImage? = nil
	) {
		self.id = id
		self.name = name
		self.origin = origin
		self.temperament = temperament
		self.lifeSpan = lifeSpan
		self.image = image
	}
}

extension Breed {
	/// List of`temperament` values from the comma-separated string
	var temperamentTags: [String] {
		guard let temperament else { return [] }
		return temperament
			.split(separator: ",")
			.map { $0.trimmingCharacters(in: .whitespaces) }
			.filter { $0.isEmpty == false }
	}
}

//
//  Breed.swift
//  BreedSheet
//
//  Created by Pim on 28/07/2026.
//

import Foundation

struct Breed: Decodable, Identifiable {

	struct BreedImage: Decodable {
		let url: URL
	}

	let id: String
	let name: String

	let image: BreedImage
}

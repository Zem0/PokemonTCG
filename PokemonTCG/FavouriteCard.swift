//
//  FavouriteCard.swift
//  PokemonTCG
//
//  Created by Duncan Horne on 20/10/2024.
//

import Foundation
import SwiftUI

struct FavouriteCard: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let imageURL: String
    let setName: String
    let setSeries: String
    let number: String
    let artist: String
    let rarity: String
    let setReleaseDate: String
}

extension FavouriteCard {
    static let sampleCard = FavouriteCard(
        id: "swsh1-1",
        name: "Pikachu EX",
        imageURL: "PikachuEX",
        setName: "SM Black Star Promos",
        setSeries: "Sun & Moon",
        number: "1/202",
        artist: "Kenji Yamamoto",
        rarity: "Ultra Rare",
        setReleaseDate: "2020-02-07"
    )
}

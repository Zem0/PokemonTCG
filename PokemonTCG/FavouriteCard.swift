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
}

//
//  FavouriteCard.swift
//  PokemonTCG
//
//  Created by Duncan Horne on 20/10/2024.
//

import Foundation
import SwiftUI

struct FavouriteCard: Identifiable, Codable {
    let id: String
    let name: String
    let imageURL: String
    // Add any other properties you want to display in the detail view
}

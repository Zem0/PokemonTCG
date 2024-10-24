//
//  FavouritesManager.swift
//  PokemonTCG
//
//  Created by Duncan Horne on 20/10/2024.
//

import Foundation
import SwiftUI

class FavouritesManager: ObservableObject {
    @Published var favourites: [FavouriteCard] = []
    
    private let saveKey = "FavouritedCards"
    
    init() {
        loadFavourites()
    }
    
    func addFavourite(_ card: FavouriteCard) {
        if !favourites.contains(where: { $0.id == card.id }) {
            favourites.append(card)
            saveFavourites()
        }
    }
    
    func isFavorite(_ card: FavouriteCard) -> Bool {
        return favourites.contains { $0.id == card.id }
    }
    
    func removeFavourite(_ card: FavouriteCard) {
        favourites.removeAll { $0.id == card.id }
        saveFavourites()
    }
    
    private func saveFavourites() {
        if let encoded = try? JSONEncoder().encode(favourites) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadFavourites() {
        if let data = UserDefaults.standard.data(forKey: saveKey) {
            if let decoded = try? JSONDecoder().decode([FavouriteCard].self, from: data) {
                favourites = decoded
            }
        }
    }
}

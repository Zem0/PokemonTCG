//
//  ContentView.swift
//  PokemonTCG
//
//  Created by Duncan Horne on 17/10/2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var favouritesManager = FavouritesManager()

    var body: some View {
        PokemonCardView(favouritesManager: favouritesManager)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//
//  FavouritesListView.swift
//  PokemonTCG
//
//  Created by Duncan Horne on 20/10/2024.
//

import SwiftUI

struct FavouritesListView: View {
    @ObservedObject var favouritesManager: FavouritesManager
    @State private var selectedCard: FavouriteCard?
    @State private var showingCardDetail = false

    var body: some View {
        List {
            ForEach(favouritesManager.favourites) { card in
                HStack {
                    AsyncImage(url: URL(string: card.imageURL)) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 50, height: 70)
                    .cornerRadius(5)
                    
                    Text(card.name)
                    
                    Spacer()
                    
                    Button(action: {
                        favouritesManager.removeFavourite(card)
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedCard = card
                    showingCardDetail = true
                    print("Card tapped: \(card.name)")
                    print("selectedCard set to: \(selectedCard?.name ?? "nil")")
                    print("showingCardDetail set to: \(showingCardDetail)")
                }
            }
        }
        .navigationTitle("Favourites")
        .sheet(isPresented: $showingCardDetail) {
            if let card = selectedCard {
                CardDetailView(card: card)
            } else {
                Text("No card selected")
            }
        }
        .onChange(of: showingCardDetail) { newValue in
            print("showingCardDetail changed to: \(newValue)")
            print("selectedCard is: \(selectedCard?.name ?? "nil")")
        }
    }
}

struct CardDetailView: View {
    let card: FavouriteCard
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 20) {
                
                AsyncImage(url: URL(string: card.imageURL)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    case .failure:
                        Image(systemName: "photo")
                            .font(.largeTitle)
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(height: 300)
                
                Text(card.name)
                    .font(.title)
                    .padding()
                
                Text("Card ID: \(card.id)")
                    .font(.subheadline)
                
                Text("Image URL: \(card.imageURL)")
                    .font(.caption)
                    .padding()
            }
        }
        .onAppear {
            print("CardDetailView appeared for card: \(card.name)")
        }
    }
}

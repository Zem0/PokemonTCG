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
                    .cornerRadius(3)
                    .overlay(
                        RoundedRectangle(cornerRadius: 3)
                            .strokeBorder(LinearGradient(colors: [.white, .black.opacity(1)], startPoint: .top, endPoint: .bottom), lineWidth: 0.5).blendMode(.overlay)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 3)
                            .stroke(.black.opacity(0.2), lineWidth: 0.5)
                    )

                    VStack(alignment: .leading, spacing: 5) {
                        Text("\(card.name)")
                            .font(.headline)
                        Text("\(card.setName) (\(card.setSeries))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation {
                        selectedCard = card
                        showingCardDetail.toggle()
                    }
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        withAnimation {
                            favouritesManager.removeFavourite(card)
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .navigationTitle("Favourites")
        .sheet(item: $selectedCard) { card in
            NavigationStack {
                CardDetailView(card: card)
//                    .navigationTitle(card.name)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                showingCardDetail = false
                                selectedCard = nil
                            }
                        }
                    }
            }
        }
    }
}

struct CardDetailView: View {
    let card: FavouriteCard
    
    var body: some View {
        List {
            Section {
                PokemonCardComponent(
                    imageURL: card.imageURL,
                    isInteractive: true
                )
                .frame(maxWidth: .infinity)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                .padding(.bottom, 20)
                .padding(.horizontal, 40)
            }
            
            Section("Card Details") {
                HStack {
                    Text(card.name)
                }
                
                HStack {
                    Text("Number")
                    Spacer()
                    Text(card.number)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Set")
                    Spacer()
                    Text(card.setName)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Series")
                    Spacer()
                    Text(card.setSeries)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Artist")
                    Spacer()
                    Text(card.artist)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Rarity")
                    Spacer()
                    Text(card.rarity)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Release Date")
                    Spacer()
                    Text(card.setReleaseDate)
                        .foregroundColor(.secondary)
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
}

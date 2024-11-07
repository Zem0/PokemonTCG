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
    @ScaledMetric(relativeTo: .body) private var fontSize: CGFloat = 20
    var body: some View {
        VStack {
            PokemonCardComponent(
                imageURL: card.imageURL,
                isInteractive: true
            )
            .frame(maxWidth: .infinity)
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
            .padding(.bottom, 20)
            .padding(.horizontal, 40)
            
            VStack {
                VStack(spacing: 0) {
                    HStack {
                        Text(card.name)
                            .fontWeight(.semibold)
                        Spacer()
                        Text(card.number)
                            .padding(4)
                            .font(.system(size: 10))
//                            .frame(alignment: .leading)
                            .background(Color(uiColor: .systemGray2))
                            .foregroundColor(.white)
                            .cornerRadius(4)
                        if card.rarity.localizedCaseInsensitiveContains("Holo") || card.rarity.localizedCaseInsensitiveContains("Shiny") {
                            Image(systemName: "sparkles")
                                .fontWeight(.black)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                    .background(Color(uiColor: .systemGray5))
                    Divider()
                     .frame(height: 1)
                     .overlay(Color(uiColor: .systemGray3))
                    
                    VStack{
                        HStack {
                            Text("Illustration by " + card.artist)
                                .foregroundColor(.secondary)
                                
                        }
                        .padding(2)
                        
                        HStack {
                            Text("Rarity")
                            Spacer()
                            Text(card.rarity)
                                .foregroundColor(.secondary)
                        }
                        .padding(2)
                        
                        HStack {
                            Text("Release Date")
                            Spacer()
                            Text(card.setReleaseDate)
                                .foregroundColor(.secondary)
                        }
                        .padding(2)
                    }
                    .padding(10)

                    Divider()
                     .frame(height: 1)
                     .overlay(Color(uiColor: .systemGray3))
                    HStack {
                        Text(card.setSeries + " -- " + card.setName)
                        Spacer()
                        Divider()
                         .frame(width: 1)
                         .frame(maxHeight: 20)
                         .overlay(Color(uiColor: .systemGray3))
                        AsyncImage(url: URL(string: card.setSymbolURL)) { image in
                            image.resizable()
                                .scaledToFit()
                                .frame(height: 20)
                        } placeholder: {
                            ProgressView()
                        }
                        Divider()
                         .frame(width: 1)
                         .frame(maxHeight: 20)
                         .overlay(Color(uiColor: .systemGray3))
                        AsyncImage(url: URL(string: card.setLogoURL)) { image in
                            image.resizable()
                                .scaledToFit()
                                .frame(height: 20)
                        } placeholder: {
                            ProgressView()
                        }
                    }
                    .foregroundColor(.secondary)
                    .padding(10)
//                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .background(Color(uiColor: .systemGray6))
            .font(.system(size: 12))
            .cornerRadius(8)
            .padding(22)
        }
    }
}

#Preview {
    NavigationStack {
        CardDetailView(card: FavouriteCard.sampleCard)
    }
}

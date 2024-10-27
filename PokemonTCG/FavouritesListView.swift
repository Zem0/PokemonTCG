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
                    selectedCard = card
                    showingCardDetail = true
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
        .sheet(isPresented: $showingCardDetail) {
            if let card = selectedCard {
                CardDetailView(card: card)
            }
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
                
                Text("Set: \(card.setName)")
                    .font(.subheadline)
                
                Text("Series: \(card.setSeries)")
                    .font(.subheadline)
            }
            .padding()
        }
    }
}

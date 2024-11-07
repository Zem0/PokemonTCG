import SwiftUI
import CoreMotion


class MotionManager: ObservableObject {
    private var motionManager = CMMotionManager()
    @Published var pitch: Double = 0.0
    @Published var roll: Double = 0.0

    init() {
        startMotionUpdates()
    }

    func startMotionUpdates() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 1.0 / 30.0
            motionManager.startDeviceMotionUpdates(to: .main) { (motion, error) in
                if let motion = motion {
                    self.pitch = motion.attitude.pitch
                    self.roll = motion.attitude.roll
                }
            }
        }
    }
}

struct PokemonCardView: View {
    @StateObject private var motion = MotionManager()
    @StateObject private var networkManager = NetworkManager()
    @ObservedObject var favouritesManager: FavouritesManager
    @State private var currentCardURL: String?
    @State private var nextCardURL: String?
    @State private var currentLocalAsset: String?
    @State private var useLocalAssets: Bool = false
    @State private var isLoadingNetworkImage: Bool = false
    @State private var currentPatternShape: PatternShape = .diamond
    @State private var nextPatternShape: PatternShape = .diamond
    @State private var isNewCardFullyLoaded: Bool = true
    @State private var currentImage: UIImage?
    @State private var nextImage: UIImage?
    @State private var currentCardArtist: String?
    @State private var currentCardRarity: String?
    @State private var currentCardName: String?
    @State private var currentCardNumber: String?
    @State private var currentCardId: String?
    @State private var showingFavorites = false
    @State private var setName: String?
    @State private var setSeries: String?
    @State private var setReleaseDate: String?
    @State private var setSymbolURL: String?
    @State private var setLogoURL: String?
    
    // List of local asset names
    private let localAssets = ["Charizard", "CharizardVmax", "DragapultVmax", "Eevee", "Gengar", "Obstagoon", "Steelix", "LugiaV", "KinglerVmax", "Mewtwo", "PikachuVmax", "PikachuEX", "PikachuEX2", "PikachuEX3", "Flapple", "Archaludon", "Deoxys", "ZoroarkV", "ZoroarkVstar", "ZoroarkVstar2"]
    
    private let wordsToCheckFor = ["Holo", "Shiny"]
    
//    func fetchNewCard() {
//        guard !isLoadingNetworkImage && isNewCardFullyLoaded else { return }
//        
//        isNewCardFullyLoaded = false
//        nextPatternShape = PatternShape.random()
//        
//        if useLocalAssets {
//            withAnimation(.easeInOut(duration: 0.3)) {
//                currentLocalAsset = localAssets.randomElement()
//                currentCardURL = nil
//                currentImage = nil
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                    currentPatternShape = nextPatternShape
//                    isNewCardFullyLoaded = true
//                }
//            }
//        } else {
//            isLoadingNetworkImage = true
//            networkManager.fetchRandomPokemonCard()
//        }
//    }
    
    func fetchNewCard() {
        guard !isLoadingNetworkImage && isNewCardFullyLoaded else { return }
        
        isNewCardFullyLoaded = false
        nextPatternShape = PatternShape.random()  // Generate a new pattern each time

        if useLocalAssets {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentLocalAsset = localAssets.randomElement()
                currentCardURL = nil
                currentImage = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    currentPatternShape = nextPatternShape  // Apply the new pattern shape
                    isNewCardFullyLoaded = true
                }
            }
        } else {
            isLoadingNetworkImage = true
            networkManager.fetchRandomPokemonCard()
        }
    }
    
    private func loadNetworkImage(from url: String) {
        guard let imageURL = URL(string: url) else {
            isLoadingNetworkImage = false
            return
        }
        
        URLSession.shared.dataTask(with: imageURL) { data, response, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.nextImage = image
                    withAnimation(.easeInOut(duration: 0.5)) {
                        self.currentImage = image
                        self.currentCardURL = url
                        self.currentCardNumber = self.networkManager.currentCardNumber
                        self.currentCardName = self.networkManager.currentCardName
                        self.currentCardId = self.networkManager.currentCardId
                        self.currentLocalAsset = nil
                        self.setSymbolURL = self.networkManager.currentSetSymbolURL
                        self.setLogoURL = self.networkManager.currentSetLogoURL
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.currentPatternShape = self.nextPatternShape
                        self.isNewCardFullyLoaded = true
                        self.isLoadingNetworkImage = false
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.isLoadingNetworkImage = false
                }
            }
        }.resume()
    }
    
    var body: some View {
        
        NavigationStack {
            VStack {
                PokemonCardComponent(
                    image: currentImage,
                    assetName: currentLocalAsset,
                    isInteractive: true,
                    patternShape: currentPatternShape,
                    onDoubleTap: { fetchNewCard() }
                )
                
                errorView
                
                HStack {
                    Button(action: { fetchNewCard() }) {
                        Label(
                            title: { Text("New Card")
                                .font(.system(size: 16, design: .rounded)
                                    .weight(.semibold))
                            },
                            icon: {}
                        )
                    }
                    .buttonStyle(.glossy(theme: .yellow))
                    
                    Button(role: .destructive, action: {
                        if let id = currentCardId,
                           let name = currentCardName,
                           let number = currentCardNumber,
                           let url = currentCardURL {
                            let card = FavouriteCard(
                                id: id,
                                name: name,
                                imageURL: url,
                                setName: networkManager.currentSetName ?? "",
                                setSeries: networkManager.currentSetSeries ?? "",
                                number: number,
                                artist: networkManager.currentCardArtist ?? "",
                                rarity: networkManager.currentCardRarity ?? "",
                                setReleaseDate: networkManager.currentSetReleaseDate ?? "",
                                setSymbolURL: setSymbolURL ?? "",
                                setLogoURL: setLogoURL ?? ""
                            )
                            if favouritesManager.isFavorite(card) {
                                favouritesManager.removeFavourite(card)
                            } else {
                                favouritesManager.addFavourite(card)
                            }
                        }
                    }) {
                        Label(
                            title: { EmptyView() },
                            icon: { Image(systemName: isFavorited ? "heart.fill" : "heart") }
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .buttonStyle(.glossy)
                .disabled(isLoadingNetworkImage)
                .opacity(isLoadingNetworkImage ? 0.5 : 1)
                
                Toggle("Use Local Images", isOn: $useLocalAssets)
                    .padding(16)
                    .background(Color(uiColor: .systemGray6))
                    .foregroundColor(Color(uiColor: .systemGray))
                    .font(.system(size: 14))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(Color(uiColor: .systemGray5), lineWidth: 2)
                    )
                    .padding(20)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if isLoadingNetworkImage {
                        ProgressView()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: FavouritesListView(favouritesManager: favouritesManager)) {
                        Image(systemName: "heart")
                    }
                }
            }
        }
        .environmentObject(favouritesManager)
        .onAppear(perform: fetchNewCard)
        .onChange(of: networkManager.pokemonCardImageURL) { oldValue, newValue in
            if let newURL = newValue {
                nextCardURL = newURL
                loadNetworkImage(from: newURL)
                setName = networkManager.currentSetName
                setSeries = networkManager.currentSetSeries
                setSymbolURL = networkManager.currentSetSymbolURL
                setLogoURL = networkManager.currentSetLogoURL
            }
        }
        .onChange(of: useLocalAssets) { oldValue, newValue in
            fetchNewCard()
        }
    }
    
    private var errorView: some View {
        Group {
            if let errorMessage = networkManager.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
    }
    
    private var newCardButton: some View {
        Button("New Card") {
            fetchNewCard()
        }
        .fontWeight(.medium)
        .foregroundStyle(.darkBrown)
        .padding()
        .background(LinearGradient(colors: [.buttonYellow1, .buttonYellow2, .buttonYellow3, .buttonYellow4, .buttonYellow2], startPoint: .top, endPoint: .bottom))
        .foregroundColor(.white)
        .cornerRadius(100)
        .disabled(isLoadingNetworkImage)
        .opacity(isLoadingNetworkImage ? 0.5 : 1)
        .overlay(
            RoundedRectangle(cornerRadius: 100)
                .fill(LinearGradient(colors: [.white.opacity(0.05), .white.opacity(0.8)], startPoint: .top, endPoint: .bottom))
                .frame( height: 25)
                .offset(y: -10)
                .blendMode(.overlay)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 100)
                .strokeBorder(LinearGradient(colors: [.buttonInsideBorderTop, .buttonInsideBorderBottom.opacity(1)], startPoint: .top, endPoint: .bottom), lineWidth: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 100)
                .stroke(Color.buttonBorder, lineWidth: 1.8)
        ).padding()
    }
    
    private var isFavorited: Bool {
        guard let id = currentCardId,
              let name = currentCardName,
              let number = currentCardNumber,
              let url = currentCardURL else {
            return false
        }
        
        let card = FavouriteCard(
            id: id,
            name: name,
            imageURL: url,
            setName: networkManager.currentSetName ?? "",
            setSeries: networkManager.currentSetSeries ?? "",
            number: number,
            artist: networkManager.currentCardArtist ?? "Unknown",
            rarity: networkManager.currentCardRarity ?? "Unknown",
            setReleaseDate: networkManager.currentSetReleaseDate ?? "",
            setSymbolURL: networkManager.currentSetSymbolURL ?? "",
            setLogoURL: networkManager.currentSetLogoURL ?? ""
        )
        return favouritesManager.isFavorite(card)
    }
}

struct PokemonCardView_Previews: PreviewProvider {
    static var previews: some View {
        PokemonCardView(favouritesManager: FavouritesManager())
    }
}

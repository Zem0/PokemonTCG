//
//  PokemonTabView.swift
//  PokemonTCG
//
//  Created by Duncan Horne on 07/11/2024.
//

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

// Utility class for haptic feedback
class HapticManager {
    static let shared = HapticManager()
    
    private let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let selectionGenerator = UISelectionFeedbackGenerator()
    private let notificationGenerator = UINotificationFeedbackGenerator()
    
    private init() {
        // Prepare generators
        impactGenerator.prepare()
        selectionGenerator.prepare()
        notificationGenerator.prepare()
    }
    
    func playNewCardHaptic() {
        impactGenerator.impactOccurred()
    }
    
    func playFavoriteAddedHaptic() {
        notificationGenerator.notificationOccurred(.success)
    }
    
    func playFavoriteRemovedHaptic() {
        notificationGenerator.notificationOccurred(.warning)
    }
}

struct PokemonTabView: View {
    @StateObject private var networkManager = NetworkManager()
    @ObservedObject var favouritesManager: FavouritesManager
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NetworkPokemonView(
                networkManager: networkManager,
                favouritesManager: favouritesManager,
                isSelected: selectedTab == 0
            )
            .tabItem {
                Label("Online Cards", systemImage: "globe")
            }
            .tag(0)
            
            LocalPokemonView(
                favouritesManager: favouritesManager,
                isSelected: selectedTab == 1
            )
            .tabItem {
                Label("Local Cards", systemImage: "rectangle.stack")
            }
            .tag(1)
        }
    }
}

struct NetworkPokemonView: View {
    @StateObject private var motion = MotionManager()
    @ObservedObject var networkManager: NetworkManager
    @ObservedObject var favouritesManager: FavouritesManager
    let isSelected: Bool
    
    @State private var currentCardURL: String?
    @State private var nextCardURL: String?
    @State private var isLoadingNetworkImage: Bool = false
    @State private var currentPatternShape: PatternShape = .diamond
    @State private var nextPatternShape: PatternShape = .diamond
    @State private var isNewCardFullyLoaded: Bool = true
    @State private var currentImage: UIImage?
    @State private var nextImage: UIImage?
    @State private var currentCardName: String?
    @State private var currentCardNumber: String?
    @State private var currentCardId: String?
    @State private var setSymbolURL: String?
    @State private var setLogoURL: String?
    @State private var hasInitiallyLoaded = false
    
    func fetchNewCard() {
        guard !isLoadingNetworkImage && isNewCardFullyLoaded else { return }
        
        HapticManager.shared.playNewCardHaptic()
        isNewCardFullyLoaded = false
        nextPatternShape = PatternShape.random()
        isLoadingNetworkImage = true
        networkManager.fetchRandomPokemonCard()
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
                    assetName: nil,
                    isInteractive: true,
                    patternShape: currentPatternShape,
                    rarity: networkManager.currentCardRarity,
                    onDoubleTap: { fetchNewCard() }
                )
                .opacity(isSelected ? 1 : 0)
                
                if let errorMessage = networkManager.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
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
                    
                    favoriteButton
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .buttonStyle(.glossy)
                .disabled(isLoadingNetworkImage)
                .opacity(isLoadingNetworkImage ? 0.5 : 1)
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
        .onChange(of: isSelected) { oldValue, newValue in
            if newValue && !hasInitiallyLoaded {
                hasInitiallyLoaded = true
                fetchNewCard()
            }
        }
        .onChange(of: networkManager.pokemonCardImageURL) { oldValue, newValue in
            if let newURL = newValue {
                nextCardURL = newURL
                loadNetworkImage(from: newURL)
            }
        }
    }
    
    private var favoriteButton: some View {
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
                    HapticManager.shared.playFavoriteRemovedHaptic()
                    favouritesManager.removeFavourite(card)
                } else {
                    HapticManager.shared.playFavoriteAddedHaptic()
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

struct LocalPokemonView: View {
    @StateObject private var motion = MotionManager()
    @ObservedObject var favouritesManager: FavouritesManager
    let isSelected: Bool
    
    @State private var currentLocalAsset: String?
    @State private var currentPatternShape: PatternShape = .diamond
    @State private var nextPatternShape: PatternShape = .diamond
    @State private var isNewCardFullyLoaded: Bool = true
    @State private var hasInitiallyLoaded = false
    
    // List of local asset names
    private let localAssets = ["Charizard", "CharizardVmax", "DragapultVmax", "Eevee", "Gengar", "Obstagoon", "Steelix", "LugiaV", "KinglerVmax", "Mewtwo", "PikachuVmax", "PikachuEX", "PikachuEX2", "PikachuEX3", "Flapple", "Archaludon", "Deoxys", "ZoroarkV", "ZoroarkVstar", "ZoroarkVstar2"]
    
    func fetchNewCard() {
        guard isNewCardFullyLoaded else { return }
        
        HapticManager.shared.playNewCardHaptic()
        isNewCardFullyLoaded = false
        nextPatternShape = PatternShape.random()
        
        withAnimation(.easeInOut(duration: 0.3)) {
            currentLocalAsset = localAssets.randomElement()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                currentPatternShape = nextPatternShape
                isNewCardFullyLoaded = true
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                PokemonCardComponent(
                    image: nil,
                    assetName: currentLocalAsset,
                    isInteractive: true,
                    patternShape: currentPatternShape,
                    onDoubleTap: { fetchNewCard() }
                )
                .opacity(isSelected ? 1 : 0)
                
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
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: FavouritesListView(favouritesManager: favouritesManager)) {
                        Image(systemName: "heart")
                    }
                }
            }
        }
        .onChange(of: isSelected) { oldValue, newValue in
            if newValue && !hasInitiallyLoaded {
                hasInitiallyLoaded = true
                fetchNewCard()
            }
        }
    }
}

struct PokemonTabView_Previews: PreviewProvider {
    static var previews: some View {
        PokemonTabView(favouritesManager: FavouritesManager())
    }
}

import SwiftUI
import CoreMotion

//import FavouriteCard
//import FavouritesManager

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
    @State private var currentCardName: String?
    @State private var currentCardId: String?
    @State private var showingFavorites = false
    @State private var setName: String?
    @State private var setSeries: String?
    
    // List of local asset names
    private let localAssets = ["Charizard", "CharizardVmax", "DragapultVmax", "Eevee", "Gengar", "Obstagoon", "Steelix", "LugiaV", "KinglerVmax", "Mewtwo", "PikachuVmax", "PikachuEX", "PikachuEX2", "PikachuEX3", "Flapple", "Archaludon"]
    
    func gradientOffset(for value: Double) -> CGFloat {
        return CGFloat(value * 0.4)
    }
    
    func gradientOpacity() -> Double {
        let motionMagnitude = sqrt(motion.pitch * motion.pitch + motion.roll * motion.roll)
        let maxMotionMagnitude = 1.0
        return min(max(motionMagnitude * 0.8 / maxMotionMagnitude, 0), 0.8)
    }
    
    func fetchNewCard() {
        guard !isLoadingNetworkImage && isNewCardFullyLoaded else { return }
        
        isNewCardFullyLoaded = false
        nextPatternShape = PatternShape.random()
        
        if useLocalAssets {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentLocalAsset = localAssets.randomElement()
                currentCardURL = nil
                currentImage = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    currentPatternShape = nextPatternShape
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
                        self.currentCardName = self.networkManager.currentCardName
                        self.currentCardId = self.networkManager.currentCardId
                        self.currentLocalAsset = nil
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
        NavigationView {
            VStack {
                
                cardView
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
                              let url = currentCardURL {
                                let card = FavouriteCard(
                                   id: id,
                                   name: name,
                                   imageURL: url,
                                   setName: networkManager.currentSetName ?? "",
                                   setSeries: networkManager.currentSetSeries ?? ""
                                )
                               if favouritesManager.isFavorite(card) {
                                   favouritesManager.removeFavourite(card)
                               } else {
                                   favouritesManager.addFavourite(card)
                               }
                   }}) {
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
                
                NavigationLink(destination: FavouritesListView(favouritesManager: favouritesManager), isActive: $showingFavorites) {
                    EmptyView()
                }
                Toggle("Use Local Images", isOn: $useLocalAssets)
                    .padding(16)
                    .background(Color(uiColor: .systemGray6))
                    .foregroundColor(Color(uiColor: .systemGray))
                    .font(.system(size: 14))
                    .cornerRadius(16).cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(Color(uiColor: .systemGray5), lineWidth: 2)
                    ).padding(20)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if isLoadingNetworkImage {
                        ProgressView()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingFavorites = true
                    } label: {
                        Label("", systemImage: "heart")
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
                // Update set information
                setName = networkManager.currentSetName
                setSeries = networkManager.currentSetSeries
            }
        }
        .onChange(of: useLocalAssets) { oldValue, newValue in
            fetchNewCard()
        }
    }
    
    // MARK: - Card View
    
    private var cardView: some View {
        ZStack {
            cardContent
            holographicEffects
        }
        .frame(width: 350, height: 490)
        .gesture(
            TapGesture(count: 2)
                .onEnded { _ in
                    fetchNewCard()
                }
        )
    }
    
    // MARK: - Card Content
    
    private var cardContent: some View {
        Group {
            if let assetName = currentLocalAsset {
                Image(assetName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .transition(.opacity.combined(with: .scale))
            } else if let image = currentImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .transition(.opacity.combined(with: .scale))
            } else {
                Color.gray.opacity(0.3)
            }
        }
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.15), radius: 6, x: motion.roll * 2, y: 5 + motion.pitch * 2)
        .shadow(color: Color.black.opacity(0.10), radius: 1, x: motion.roll * 2, y: 3 + motion.pitch * 2)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(LinearGradient(colors: [.white, .black.opacity(1)], startPoint: .top, endPoint: .bottom), lineWidth: 1.5).blendMode(.overlay)
        )
    }
    
    private var holographicEffects: some View {
        Group {
            LinearGradient(
                gradient: Gradient(colors: [.blue, .purple, .red, .yellow]),
                startPoint: UnitPoint(
                    x: 0.1 + gradientOffset(for: motion.roll),
                    y: 0 + gradientOffset(for: motion.pitch)
                ),
                endPoint: UnitPoint(
                    x: 1.0 - gradientOffset(for: motion.roll),
                    y: 1.0 - gradientOffset(for: motion.pitch)
                )
            )
            .mask(SVGPattern(shape: currentPatternShape))
            .opacity(gradientOpacity())
            .blendMode(.overlay)
            .cornerRadius(12)
            
            LinearGradient(colors: [Color.grBlack, Color.grBlue, Color.grBlack, Color.grBlue, Color.grBlack, Color.grBlue, Color.grBlack, Color.grBlue, Color.grBlack, Color.grBlue],
                startPoint: UnitPoint(
                    x: UnitPoint.topLeading.x + gradientOffset(for: motion.roll),
                    y: UnitPoint.topLeading.y + gradientOffset(for: motion.pitch)
                ), endPoint: UnitPoint(
                    x: UnitPoint.bottom.x + gradientOffset(for: motion.roll),
                    y: UnitPoint.bottom.y + gradientOffset(for: motion.pitch)
                )
            )
            .mask(SVGPattern(shape: currentPatternShape))
            .opacity(gradientOpacity())
            .blendMode(.colorDodge)
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
//        .overlay(
//            RoundedRectangle(cornerRadius: 100).frame(height: 30), alignment: .topLeading
//        )
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
    
    private var favouriteButton: some View {
        Button(action: {
            if let id = currentCardId,
               let name = currentCardName,
               let url = currentCardURL,
               let setName = networkManager.currentSetName,
               let setSeries = networkManager.currentSetSeries {
                let card = FavouriteCard(
                    id: id,
                    name: name,
                    imageURL: url,
                    setName: setName,
                    setSeries: setSeries
                )
                if favouritesManager.isFavorite(card) {
                    favouritesManager.removeFavourite(card)
                } else {
                    favouritesManager.addFavourite(card)
                }
            }
        }) {
            Image(systemName: isFavorited ? "heart.fill" : "heart")
                .foregroundColor(.white)
                .padding()
                .background(isFavorited ? LinearGradient(colors: [.buttonYellow1, .buttonYellow2, .buttonYellow3, .buttonYellow4, .buttonYellow2], startPoint: .top, endPoint: .bottom) : LinearGradient(colors: [.buttonGrey1, .buttonGrey2, .buttonGrey3, .buttonGrey4, .buttonGrey5], startPoint: .top, endPoint: .bottom))
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .strokeBorder(LinearGradient(colors: [.buttonGreyInsideBorderTop, .buttonGreyInsideBorderMiddle, .buttonGreyInsideBorderBottom.opacity(1)], startPoint: .top, endPoint: .bottom), lineWidth: 3)
                )
                .overlay(
                    Circle()
                        .stroke(isFavorited ? Color.yellow : Color.buttonGreyBorder, lineWidth: 1.8)
                )
        }
        .disabled(currentCardId == nil || currentCardName == nil || currentCardURL == nil)
    }
    
    private var isFavorited: Bool {
        guard let id = currentCardId, let name = currentCardName, let url = currentCardURL else {
            return false
        }
        let card = FavouriteCard(id: id, name: name, imageURL: url, setName: "", setSeries: "")
        return favouritesManager.isFavorite(card)
    }
}

struct PokemonCardView_Previews: PreviewProvider {
    static var previews: some View {
        PokemonCardView(favouritesManager: FavouritesManager())
    }
}

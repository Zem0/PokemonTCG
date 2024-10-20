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
    
    // List of local asset names
    private let localAssets = ["Charizard", "CharizardVmax", "DragapultVmax", "Eevee", "Gengar", "Obstagoon", "Steelix", "LugiaV", "KinglerVmax", "Mewtwo", "PikachuVmax"]
    
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
        VStack {
            Toggle("Use Local Assets", isOn: $useLocalAssets)
                .padding()
            
            cardView
            errorView
            newCardButton
        }
        .onAppear(perform: fetchNewCard)
        .onChange(of: networkManager.pokemonCardImageURL) { oldValue, newValue in
            if let newURL = newValue {
                nextCardURL = newURL
                loadNetworkImage(from: newURL)
            }
        }
        .onChange(of: useLocalAssets) { oldValue, newValue in
            fetchNewCard()
        }
    }
    
    private var cardView: some View {
        ZStack {
            cardContent
            holographicEffects
        }
        .frame(width: 300, height: 420)
        .gesture(
            TapGesture(count: 2)
                .onEnded { _ in
                    fetchNewCard()
                }
        )
    }
    
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
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.15), radius: 5, x: motion.roll * 5, y: 2 + motion.pitch * 5)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(LinearGradient(colors: [.white, .black.opacity(1)], startPoint: .top, endPoint: .bottom), lineWidth: 1).blendMode(.overlay)
        )
        .overlay(
            Group {
                if isLoadingNetworkImage {
                    ProgressView()
                        .scaleEffect(2)
                        .frame(width: 300, height: 420)
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(12)
                }
            }
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
        .overlay(
            RoundedRectangle(cornerRadius: 100)
                .stroke(Color.buttonBorder, lineWidth: 3)
        ).padding()
    }
}

struct PokemonCardView_Previews: PreviewProvider {
    static var previews: some View {
        PokemonCardView()
    }
}

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
            motionManager.deviceMotionUpdateInterval = 1.0 / 30.0  // Reduced update frequency
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
    
    func gradientOffset(for value: Double) -> CGFloat {
        return CGFloat(value * 0.4)
    }
    
    func gradientOpacity() -> Double {
        let motionMagnitude = sqrt(motion.pitch * motion.pitch + motion.roll * motion.roll)
        let maxMotionMagnitude = 1.0
        return min(max(motionMagnitude * 0.8 / maxMotionMagnitude, 0), 0.8)
    }
    
    func fetchNewCard() {
        networkManager.fetchRandomPokemonCard()
    }
    
    var body: some View {
        VStack {
            cardView
            errorView
            newCardButton.padding()
        }
        .onAppear(perform: fetchNewCard)
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
            if networkManager.isLoading {
                ProgressView()
                    .scaleEffect(2)
            } else if let imageURL = networkManager.pokemonCardImageURL {
                AsyncImage(url: URL(string: imageURL)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.15), radius: 5, x: motion.roll * 5, y: 2 + motion.pitch * 5)
                            .shadow(color: Color.yellow.opacity(0.3), radius: 15, x: motion.roll * 5, y: 10 + motion.pitch * 5)
                    case .failure(_):
                        Text("Failed to load image")
                    case .empty:
                        ProgressView()
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Image("pokemon_card")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .cornerRadius(12)
            }
        }
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
            .mask(DiamondPattern())
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
            .mask(DiamondPattern())
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
        Button("Get New Card") {
            fetchNewCard()
        }
        .padding()
        .background(Color.blue)
        .foregroundColor(.white)
        .cornerRadius(8)
    }
}

struct PokemonCardView_Previews: PreviewProvider {
    static var previews: some View {
        PokemonCardView()
    }
}

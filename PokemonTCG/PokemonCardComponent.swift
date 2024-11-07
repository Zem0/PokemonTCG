//
//  PokemonCardComponent.swift
//  PokemonTCG
//
//  Created by Duncan Horne on 27/10/2024.
//

import SwiftUI
import CoreMotion

struct PokemonCardComponent: View {
    var image: UIImage?
    var imageURL: String?
    var assetName: String?
    var isInteractive: Bool
    var patternShape: PatternShape
    var onDoubleTap: (() -> Void)?

    @StateObject private var motion = MotionManager()

    init(image: UIImage? = nil,
         imageURL: String? = nil,
         assetName: String? = nil,
         isInteractive: Bool = false,
         patternShape: PatternShape = .diamond,
         onDoubleTap: (() -> Void)? = nil) {
        self.image = image
        self.imageURL = imageURL
        self.assetName = assetName
        self.isInteractive = isInteractive
        self.patternShape = patternShape
        self.onDoubleTap = onDoubleTap
    }

    func gradientOffset(for value: Double) -> CGFloat {
        return CGFloat(value * 0.4)
    }

    func gradientOpacity() -> Double {
        let motionMagnitude = sqrt(motion.pitch * motion.pitch + motion.roll * motion.roll)
        let maxMotionMagnitude = 1.0
        return min(max(motionMagnitude * 0.8 / maxMotionMagnitude, 0), 0.8)
    }

    var body: some View {
        ZStack {
            cardContent
                .frame(width: 300, height: 490)
                .blur(radius: 20)
                .opacity(0.7)
                .offset(y: 10)
            cardContent
            if isInteractive {
                holographicEffects
            }
        }
        .frame(width: 350, height: 490)
        .gesture(
            TapGesture(count: 2)
                .onEnded { _ in
                    onDoubleTap?()
                }
        )
    }

    private var cardContent: some View {
        Group {
            if let assetName = assetName {
                Image(assetName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else if let imageURL = imageURL {
                AsyncImage(url: URL(string: imageURL)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        Image(systemName: "photo")
                            .font(.largeTitle)
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Color.gray.opacity(0.3)
            }
        }
        .cornerRadius(16)
        .shadow(
            color: Color.black.opacity(0.15),
            radius: 6,
            x: isInteractive ? motion.roll * 2 : 0,
            y: isInteractive ? 5 + motion.pitch * 2 : 5
        )
        .blendMode(.overlay)
        .shadow(
            color: Color.black.opacity(0.10),
            radius: 3,
            x: isInteractive ? motion.roll * 2 : 0,
            y: isInteractive ? 3 + motion.pitch * 2 : 3
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    LinearGradient(
                        colors: [.white, .black.opacity(1)],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 1.5
                )
                .blendMode(.overlay)
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
            .mask(SVGPattern(shape: patternShape))
            .opacity(gradientOpacity())
            .blendMode(.overlay)
            .cornerRadius(16)

            LinearGradient(
                colors: [
                    Color.grBlack, Color.grBlue, Color.grBlack,
                    Color.grBlue, Color.grBlack, Color.grBlue,
                    Color.grBlack, Color.grBlue, Color.grBlack,
                    Color.grBlue
                ],
                startPoint: UnitPoint(
                    x: UnitPoint.topLeading.x + gradientOffset(for: motion.roll),
                    y: UnitPoint.topLeading.y + gradientOffset(for: motion.pitch)
                ),
                endPoint: UnitPoint(
                    x: UnitPoint.bottom.x + gradientOffset(for: motion.roll),
                    y: UnitPoint.bottom.y + gradientOffset(for: motion.pitch)
                )
            )
            .mask(SVGPattern(shape: patternShape))
            .opacity(gradientOpacity())
            .blendMode(.colorDodge)
            .cornerRadius(16)
            
            LinearGradient(
                colors: [
                    .yellow, .pink, .purple, .mint, .teal
                ],
                startPoint: UnitPoint(
                    x: UnitPoint.topLeading.x + gradientOffset(for: motion.roll),
                    y: UnitPoint.topLeading.y + gradientOffset(for: motion.pitch)
                ),
                endPoint: UnitPoint(
                    x: UnitPoint.bottom.x + gradientOffset(for: motion.roll),
                    y: UnitPoint.bottom.y + gradientOffset(for: motion.pitch)
                )
            )
            .mask(ShapedSparkleView(
                particleCount: 1000,
                particleSize: 30,
                shape: .star,
                fill: .linearGradient(
                    colors: [.blue, .purple, .red, .yellow],
                    startPoint: .top,
                    endPoint: .bottom
                )
            ))
            .opacity(gradientOpacity())
            .blendMode(.overlay)
            .cornerRadius(16)
            
        }
    }
}

// Preview
struct PokemonCardComponent_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Interactive card with local asset
            PokemonCardComponent(
                assetName: "PikachuEX",
                isInteractive: true,
                onDoubleTap: { print("Double tapped!") }
            )
        }
    }
}

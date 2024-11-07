//
//  CustomShapesSparkleView.swift
//  PokemonTCG
//
//  Created by Duncan Horne on 06/11/2024.
//
import SwiftUI

enum ParticleShape {
    case circle
    case star
    case diamond
    case custom(Path)
    
    func path(in rect: CGRect) -> Path {
        switch self {
        case .circle:
            return Circle().path(in: rect)
        case .star:
            return createStarPath(in: rect)
        case .diamond:
            return createDiamondPath(in: rect)
        case .custom(let path):
            return path
        }
    }
    
    private func createStarPath(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * 0.4
        let points = 5
        
        var path = Path()
        
        for i in 0..<points * 2 {
            let radius = i.isMultiple(of: 2) ? outerRadius : innerRadius
            let angle = Double(i) * .pi / Double(points)
            let x = center.x + cos(angle) * radius
            let y = center.y + sin(angle) * radius
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        return path
    }
    
    private func createDiamondPath(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.closeSubpath()
        return path
    }
}

enum ParticleFill {
    case solid(Color)
    case linearGradient(colors: [Color], startPoint: UnitPoint = .topLeading, endPoint: UnitPoint = .bottomTrailing)
    case radialGradient(colors: [Color], center: UnitPoint = .center, startRadius: CGFloat = 0, endRadius: CGFloat? = nil)
    case angularGradient(colors: [Color], center: UnitPoint = .center, startAngle: Angle = .zero, endAngle: Angle = .degrees(360))
}

struct Particle: Identifiable {
    let id = UUID()
    let position: CGPoint
    let scale: CGFloat
    let opacity: Double
    let duration: Double
    let rotation: Double
}

struct ShapeView: Shape {
    let shape: ParticleShape
    
    func path(in rect: CGRect) -> Path {
        shape.path(in: rect)
    }
}

struct ParticleView: View {
    let particle: Particle
    let shape: ParticleShape
    let fill: ParticleFill
    let size: CGFloat
    
    var body: some View {
        ShapeView(shape: shape)
            .fillWithStyle(fill)
            .frame(width: size, height: size)
            .scaleEffect(particle.scale)
            .opacity(particle.opacity)
            .rotationEffect(.degrees(particle.rotation))
            .position(particle.position)
    }
}

extension Shape {
    @ViewBuilder
    func fillWithStyle(_ fill: ParticleFill) -> some View {
        switch fill {
        case .solid(let color):
            self.fill(color)
        case .linearGradient(let colors, let startPoint, let endPoint):
            self.fill(LinearGradient(colors: colors, startPoint: startPoint, endPoint: endPoint))
        case .radialGradient(let colors, let center, let startRadius, let endRadius):
            self.fill(RadialGradient(colors: colors,
                                   center: center,
                                   startRadius: startRadius,
                                   endRadius: endRadius ?? 50))
        case .angularGradient(let colors, let center, let startAngle, let endAngle):
            self.fill(AngularGradient(colors: colors,
                                    center: center,
                                    startAngle: startAngle,
                                    endAngle: endAngle))
        }
    }
}

struct ShapedSparkleView: View {
    let particleCount: Int
    let particleSize: CGFloat
    let shape: ParticleShape
    let fill: ParticleFill
    
    @State private var particles: [Particle] = []
    @State private var phase: CGFloat = 0
    
    init(
        particleCount: Int = 30,
        particleSize: CGFloat = 4,
        shape: ParticleShape = .circle,
        fill: ParticleFill = .solid(.white)
    ) {
        self.particleCount = particleCount
        self.particleSize = particleSize
        self.shape = shape
        self.fill = fill
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    ParticleView(
                        particle: particle,
                        shape: shape,
                        fill: fill,
                        size: particleSize
                    )
                    .animation(
                        Animation
                            .easeInOut(duration: particle.duration)
                            .repeatForever(autoreverses: true),
                        value: phase
                    )
                }
            }
            .onAppear {
                createParticles(in: geometry.size)
                withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
        }
    }
    
    private func createParticles(in size: CGSize) {
        particles = (0..<particleCount).map { _ in
            let position = CGPoint(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: 0...size.height)
            )
            let scale = CGFloat.random(in: 0.3...1.0)
            let opacity = Double.random(in: 0.3...0.9)
            let duration = Double.random(in: 1.0...2.0)
            let rotation = Double.random(in: 0...360)
            
            return Particle(
                position: position,
                scale: scale,
                opacity: opacity,
                duration: duration,
                rotation: rotation
            )
        }
    }
}

#Preview {
    ZStack {
        TabView {
            // Linear Gradient Stars
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                ShapedSparkleView(
                    particleCount: 50,
                    particleSize: 12,
                    shape: .star,
                    fill: .linearGradient(
                        colors: [.yellow, .orange, .red],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            .tabItem {
                Label("Linear", systemImage: "star.fill")
            }
            
            // Radial Gradient Diamonds
            ZStack {
                Color.indigo.opacity(0.8).edgesIgnoringSafeArea(.all)
                ShapedSparkleView(
                    particleCount: 30,
                    particleSize: 10,
                    shape: .diamond,
                    fill: .radialGradient(
                        colors: [.white, .blue, .purple],
                        center: .center,
                        startRadius: 0,
                        endRadius: 10
                    )
                )
            }
            .tabItem {
                Label("Radial", systemImage: "diamond.fill")
            }
            
            // Angular Gradient Circles
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                ShapedSparkleView(
                    particleCount: 40,
                    particleSize: 8,
                    shape: .circle,
                    fill: .angularGradient(
                        colors: [.blue, .purple, .pink, .blue],
                        center: .center
                    )
                )
            }
            .tabItem {
                Label("Angular", systemImage: "circle.fill")
            }
        }
    }
}

//
//  GlossyButtonStyle.swift
//  PokemonTCG
//
//  Created by Duncan Horne on 22/10/2024.
//

import Foundation
import SwiftUI

// MARK: - Button Theme

enum GlossyButtonTheme {
    case neutral
    case yellow
    case red
    
    var colors: (
        base: [Color],
        innerStrokeColors: [Color],
        reflection: [Color],
        shadows: [Color],
        strokeColorTop: Color,
        strokeColorBottom: Color,
        textShadowTop: Color,
        textShadowBottom: Color
    ) {
        switch self {
        case .neutral:
            return (
                base: [
                    Color(red: 58/255, green: 63/255, blue: 66/255),
                    Color(red: 56/255, green: 61/255, blue: 62/255),
                    Color(red: 97/255, green: 100/255, blue: 106/255)
                ],
                innerStrokeColors: [
                    Color(red: 202/255, green: 209/255, blue: 224/255),
                    Color(red: 105/255, green: 110/255, blue: 116/255),
                    Color(red: 75/255, green: 80/255, blue: 82/255)
                ],
                reflection: [
                    Color(red: 171/255, green: 173/255, blue: 179/255),
                    Color(red: 75/255, green: 79/255, blue: 80/255)
                ],
                shadows: [
                    Color(red: 60/255, green: 64/255, blue: 66/255),
                    Color(red: 47/255, green: 51/255, blue: 52/255)
                ],
                strokeColorTop: Color(red: 48/255, green: 52/255, blue: 52/255),
                strokeColorBottom: Color(red: 37/255, green: 40/255, blue: 42/255),
                textShadowTop: Color(red: 48/255, green: 52/255, blue: 52/255),
                textShadowBottom: Color(red: 138/255, green: 138/255, blue: 138/255)
            )
        case .yellow:
            return (
                base: [
                    Color(red: 255/255, green: 242/255, blue: 123/255),
                    Color(red: 255/255, green: 204/255, blue: 0/255),
                    Color(red: 255/255, green: 238/255, blue: 83/255)
                ],
                innerStrokeColors: [
                    Color(red: 255/255, green: 249/255, blue: 236/255),
                    Color(red: 255/255, green: 243/255, blue: 118/255),
                    Color(red: 255/255, green: 214/255, blue: 54/255)
                ],
                reflection: [
                    Color(red: 255/255, green: 241/255, blue: 119/255).opacity(0),
                    Color(red: 255/255, green: 241/255, blue: 119/255).opacity(0.2),
                    Color(red: 255/255, green: 255/255, blue: 139/255).opacity(0.8),
                    Color(red: 255/255, green: 255/255, blue: 139/255)
                ],
                shadows: [
                    Color(red: 255/255, green: 214/255, blue: 0/255),
                    Color(red: 255/255, green: 214/255, blue: 0/255),
                ],
                strokeColorTop: Color(red: 255/255, green: 203/255, blue: 2/255),
                strokeColorBottom: Color(red: 255/255, green: 153/255, blue: 0/255),
                textShadowTop: Color(red: 254/255, green: 212/255, blue: 28/255),
                textShadowBottom: Color(red: 255/255, green: 255/255, blue: 255/255)
            )
        case .red:
            return (
                base: [
                    Color(red: 220/255, green: 38/255, blue: 38/255),
                    Color(red: 220/255, green: 38/255, blue: 38/255),
                    Color(red: 185/255, green: 28/255, blue: 28/255)
                ],
                innerStrokeColors: [
                    Color(red: 58/255, green: 63/255, blue: 66/255),
                    Color(red: 56/255, green: 61/255, blue: 62/255),
                    Color(red: 73/255, green: 76/255, blue: 80/255)
                ],
                reflection: [
                    Color(red: 255/255, green: 242/255, blue: 118/255),
                    Color(red: 255/255, green: 255/255, blue: 139/255)
                ],
                shadows: [
                    Color(red: 185/255, green: 28/255, blue: 28/255),
                    Color(red: 153/255, green: 27/255, blue: 27/255)
                ],
                strokeColorTop: Color(red: 127/255, green: 29/255, blue: 29/255),
                strokeColorBottom: Color(red: 255/255, green: 203/255, blue: 2/255),
                textShadowTop: Color(red: 48/255, green: 52/255, blue: 52/255),
                textShadowBottom: Color(red: 37/255, green: 40/255, blue: 42/255)
            )
        }
    }
    
    var labelColor: Color {
        switch self {
        case .neutral:
            return .white
        case .yellow:
            return Color(red: 113/255, green: 61/255, blue: 1/255)
        case .red:
            return .white
        }
    }
}

// MARK: - Custom Button Style

struct GlossyButtonStyle: ButtonStyle {
    // MARK: Properties
    let theme: GlossyButtonTheme
    
    // MARK: Metrics
    @ScaledMetric private var cornerRadius = 20
    @ScaledMetric private var horizontalLabelPadding = 12
    @ScaledMetric private var verticalLabelPadding = 8
    @ScaledMetric private var shadowRadius = 2
    @ScaledMetric private var shadowVerticalOffset = 1
    
    // MARK: Immutable Properties
    private let strokeLineWidth = 1.5
    
    init(theme: GlossyButtonTheme = .neutral) {
        self.theme = theme
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .labelStyle(GlossyLabelStyle(theme: theme))
            .padding(.horizontal, horizontalLabelPadding)
            .padding(.vertical, verticalLabelPadding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .foregroundStyle(
                        LinearGradient(
                            colors: theme.colors.base,
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        // Top reflection
                        ReflectionContainer {
                            UnevenRoundedRectangle(
                                cornerRadii: .init(
                                    topLeading: cornerRadius,
                                    bottomLeading: (cornerRadius * 0.43).rounded(.down),
                                    bottomTrailing: (cornerRadius * 0.43).rounded(.down),
                                    topTrailing: cornerRadius
                                ),
                                style: .continuous
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: theme.colors.reflection,
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .opacity(1)
                        }
                    )
                    .overlay(
                        // Inner light stroke
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: theme.colors.innerStrokeColors,
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: strokeLineWidth
                            )
                    ).clipShape(Capsule())
                    .overlay(
                        // Outer shadow stroke
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .inset(by: -strokeLineWidth)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        theme.colors.strokeColorTop.opacity(1),
                                        theme.colors.strokeColorBottom
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: strokeLineWidth
                            )
                            .opacity(1)
                    )
            )
            .shadow(
                color: theme.colors.shadows[0].opacity(0.25),
                radius: shadowRadius * 3,
                x: 0,
                y: shadowVerticalOffset * 4
            )
            .shadow(
                color: theme.colors.shadows[1].opacity(0.1),
                radius: shadowRadius * 5,
                x: 0,
                y: shadowVerticalOffset * 8
            )
            .padding(.leading, 2)
            .environment(\.buttonRole, configuration.role)
    }
}

// MARK: - Custom Layout

private struct ReflectionContainer: Layout {
   func sizeThatFits(
      proposal: ProposedViewSize,
      subviews: Subviews,
      cache: inout ()
   ) -> CGSize {
      let safeProposal = proposal.replacingUnspecifiedDimensions()
      return CGSize(width: safeProposal.width, height: safeProposal.height)
   }

   func placeSubviews(
      in bounds: CGRect,
      proposal: ProposedViewSize,
      subviews: Subviews,
      cache: inout ()
   ) {
      subviews.first!.place(
         at: CGPoint(x: bounds.minX, y: bounds.minY),
         proposal: .init(
            width: proposal.width ?? 0,
            height: (proposal.height ?? 0) / 1.85
         )
      )
   }
}

// MARK: - Custom Label Style

private struct GlossyLabelStyle: LabelStyle {
    // MARK: Properties
    let theme: GlossyButtonTheme
    
    // MARK: Environment
    @Environment(\.buttonRole) private var role
    
    // MARK: Metrics
    @ScaledMetric private var shadowRadius = 2
    @ScaledMetric private var shadowVerticalOffset = 1
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.icon
            configuration.title
        }
        .font(.callout.weight(.medium))
        .foregroundStyle(
            role == .destructive
            ? AnyShapeStyle(Color.red.gradient)
            : AnyShapeStyle(theme.labelColor.gradient)
        )
        .shadow(
            color: theme.colors.textShadowTop,
            radius: shadowRadius - shadowRadius,
            x: 0,
            y: -shadowVerticalOffset / 1.5
        )
        .shadow(
            color: theme.colors.textShadowBottom,
            radius: shadowRadius - shadowRadius,
            x: 0,
            y: shadowVerticalOffset / 1.5
        )
    }
}

// MARK: - Quality Of Life

extension ButtonStyle where Self == GlossyButtonStyle {
    static var glossy: Self { GlossyButtonStyle() }
    static func glossy(theme: GlossyButtonTheme) -> Self { GlossyButtonStyle(theme: theme) }
}

// MARK: - Environment Extensions

private enum ButtonRoleEnvironmentKey: EnvironmentKey {
   static let defaultValue: ButtonRole? = nil
}

extension EnvironmentValues {
   var buttonRole: ButtonRole? {
      get { self[ButtonRoleEnvironmentKey.self] }
      set { self[ButtonRoleEnvironmentKey.self] = newValue }
   }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        Button(action: {}) {
            Label(
                title: { Text("Default Button")
                    .font(.system(size: 16, design: .rounded)
                        .weight(.semibold))
                },
                icon: { Image(systemName: "star")
                    .font(.system(size: 16, design: .rounded)
                        .weight(.semibold))}
            )
        }
        .buttonStyle(.glossy)
        
        Button(action: {}) {
            Label(
                title: { Text("Yellow Button")
                    .font(.system(size: 16, design: .rounded)
                        .weight(.semibold))
                },
                icon: { Image(systemName: "star")
                    .font(.system(size: 16, design: .rounded)
                        .weight(.semibold))}
            )
        }
        .buttonStyle(.glossy(theme: .yellow))
        
        Button(action: {}) {
            Label(
                title: { Text("Red Button")
                    .font(.system(size: 18, design: .rounded)
                        .weight(.semibold))
                },
                icon: { Image(systemName: "star")
                    .font(.system(size: 18, design: .rounded)
                        .weight(.semibold))}
            )
        }
        .buttonStyle(.glossy(theme: .red))
    }
    .padding()
}

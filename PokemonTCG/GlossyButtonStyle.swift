//
//  GlossyButtonStyle.swift
//  PokemonTCG
//
//  Created by Duncan Horne on 22/10/2024.
//

import Foundation
import SwiftUI

// MARK: - Custom Button Style

struct GlossyButtonStyle: ButtonStyle {
   // MARK: Metrics
   @ScaledMetric private var cornerRadius = 20
   @ScaledMetric private var horizontalLabelPadding = 12
   @ScaledMetric private var verticalLabelPadding = 8
   @ScaledMetric private var shadowRadius = 2
   @ScaledMetric private var shadowVerticalOffset = 1

   // MARK: Immutable Properties
   private let strokeLineWidth = 1.5

   func makeBody(configuration: Configuration) -> some View {
      configuration.label
         .labelStyle(.glossy)
         .padding(.horizontal, horizontalLabelPadding)
         .padding(.vertical, verticalLabelPadding)
         .background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
               .foregroundStyle(
                  LinearGradient(
                     colors: [
                        Color(red: 58/255, green: 63/255, blue: 66/255),
                        Color(red: 58/255, green: 63/255, blue: 66/255),
                        Color(red: 73/255, green: 76/255, blue: 80/255)
                     ],
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
                           colors: [
                              Color.white.opacity(0.40),
                              Color.white.opacity(0.08)
                           ],
                           startPoint: .top,
                           endPoint: .bottom
                        )
                     )
                     .blendMode(.plusLighter)
                     .opacity(1)
                  }
               )
               .overlay(
                  // Inner light stroke
                  RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                     .strokeBorder(
                        LinearGradient(
                           colors: [
                              Color.white,
                              Color.white.opacity(0.2),
                              Color.white.opacity(0.24)
                           ],
                           startPoint: .top,
                           endPoint: .bottom
                        ),
                        lineWidth: strokeLineWidth
                     )
                     .blendMode(.plusLighter)
                     .opacity(0.3)
               ).clipShape(Capsule())
               .overlay(
                  // Outer shadow stroke
                  RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                     .inset(by: -strokeLineWidth)
                     .strokeBorder(
                        LinearGradient(
                           colors: [
                              Color.black.opacity(1),
                              Color.black
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
            color: .black.opacity(0.2),
            radius: shadowRadius,
            x: 0,
            y: shadowVerticalOffset
         )
         .shadow(
            color: Color(red: 60/255, green: 64/255, blue: 66/255).opacity(0.25),
            radius: shadowRadius * 3,
            x: 0,
            y: shadowVerticalOffset * 4
         )
         .shadow(
            color: Color(red: 47/255, green: 51/255, blue: 52/255).opacity(0.1),
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
         : AnyShapeStyle(Color.white.gradient.opacity(0.9))
      )
      .shadow(
         color: .black.opacity(role == .destructive ? 0.3 : 0.6),
         radius: shadowRadius,
         x: 0,
         y: shadowVerticalOffset
      )
   }
}

// MARK: - Quality Of Life

extension ButtonStyle where Self == GlossyButtonStyle {
   static var glossy: Self { GlossyButtonStyle() }
}

extension LabelStyle where Self == GlossyLabelStyle {
   static var glossy: Self { GlossyLabelStyle() }
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
   HStack {
      Button(action: {}) {
         Label(
            title: { Text("Favourite")
                .font(
                    .system(size: 16, design: .rounded)
                    .weight(.semibold))
            },
            icon: { Image(systemName: "star")
                    .font(
                        .system(size: 16, design: .rounded)
                        .weight(.semibold))}
         )
      }
      Button(role: .destructive, action: {}) {
         Label(
            title: { EmptyView() },
            icon: { Image(systemName: "trash.fill") }
         )
      }
   }
//   .padding(.horizontal, 16)
//   .padding(.vertical, 16)
//   .background(
//      RoundedRectangle(cornerRadius: 30, style: .continuous)
//         .foregroundStyle(
//            LinearGradient(
//               colors: [
//                  Color(red: 72/255, green: 77/255, blue: 81/255),
//                  Color(red: 46/255, green: 48/255, blue: 54/255)
//               ],
//               startPoint: .top,
//               endPoint: .bottom
//            )
//         )
//   )
   .buttonStyle(.glossy)
}

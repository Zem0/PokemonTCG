//
//  PatternView.swift
//  PokemonTCG
//
//  Created by Duncan Horne on 17/10/2024.
//

import SwiftUI

struct PatternView: View {
    var body: some View {
        ZStack {
            Image("SquarePatternwGradient").resizable()
            LinearGradient(gradient: Gradient(colors: [.blue, .purple, .red, .yellow]), startPoint: .top, endPoint: .bottom).blendMode(.screen)
        }
    }
}

#Preview {
    PatternView()
}

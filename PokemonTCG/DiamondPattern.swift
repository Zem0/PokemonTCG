//
//  DiamondPattern.swift
//  PokemonTCG
//
//  Created by Duncan Horne on 17/10/2024.
//

import SwiftUI

struct DiamondPattern: View {
    let rows = 20
    let cols = 16

    var body: some View {
        VStack {
            GeometryReader { gr in
                let width = gr.size.width / CGFloat(cols)
                let height = gr.size.height / CGFloat(rows)

                VStack(spacing:0) {
                    ForEach(0..<rows) { _ in
                        HStack(spacing:0) {
                            Group {
                                ForEach(0..<cols) { _ in
                                    DiamondShape()
                                        .stroke(Color.red)
                                        .frame(width: width, height: height)
                                }
                            }
                        }
                    }
                }
            }
            .frame(width: 300, height: 420)
        }
    }
}

#Preview {
    DiamondPattern()
}

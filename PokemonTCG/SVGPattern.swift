//
//  DiamondPattern.swift
//  PokemonTCG
//
//  Created by Duncan Horne on 17/10/2024.
//

import SwiftUI

enum PatternShape {
    case diamond
    case tornado

    static func random() -> PatternShape {
        let allCases: [PatternShape] = [.diamond, .tornado]
        return allCases.randomElement() ?? .diamond
    }
}

struct SVGPattern: View {
    let rows = 20
    let cols = 16
    let selectedShape: PatternShape

    init(shape: PatternShape) {
        selectedShape = shape
    }

    var body: some View {
        VStack {
            GeometryReader { gr in
                let width = gr.size.width / CGFloat(cols)
                let height = gr.size.height / CGFloat(rows)

                VStack(spacing: 0) {
                    ForEach(0..<rows, id: \.self) { row in
                        HStack(spacing: 0) {
                            ForEach(0..<cols, id: \.self) { col in
                                Group {
                                    switch selectedShape {
                                    case .diamond:
                                        DiamondShape()
                                            .stroke(Color.red)
                                    case .tornado:
                                        TornadoShape()
                                            .stroke(Color.red)
                                    // Add more cases here for additional shapes
                                    }
                                }
                                .frame(width: width, height: height)
                            }
                        }
                    }
                }
            }
            .frame(width: 350, height: 490)
        }
    }
}

struct SVGPattern_Previews: PreviewProvider {
    static var previews: some View {
        SVGPattern(shape: .diamond)
            .previewLayout(.fixed(width: 300, height: 420))
        
        SVGPattern(shape: .tornado)
            .previewLayout(.fixed(width: 300, height: 420))
    }
}

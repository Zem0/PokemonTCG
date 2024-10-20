//
//  TornadoShape.swift
//  PokemonTCG
//
//  Created by Duncan Horne on 20/10/2024.
//

import SwiftUI

struct TornadoShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.26852*width, y: 0.14844*height))
        path.addLine(to: CGPoint(x: 0.49074*width, y: 0.25781*height))
        path.addLine(to: CGPoint(x: 0.49074*width, y: 0.73438*height))
        path.addLine(to: CGPoint(x: 0.72222*width, y: 0.85156*height))
        path.move(to: CGPoint(x: 0.97222*width, y: 0.51563*height))
        path.addLine(to: CGPoint(x: 0.75*width, y: 0.61719*height))
        path.addLine(to: CGPoint(x: 0.25*width, y: 0.38281*height))
        path.addLine(to: CGPoint(x: 0.02778*width, y: 0.48438*height))
        path.move(to: CGPoint(x: 0.25*width, y: 0.82813*height))
        path.addLine(to: CGPoint(x: 0.25*width, y: 0.61719*height))
        path.addLine(to: CGPoint(x: 0.75*width, y: 0.375*height))
        path.addLine(to: CGPoint(x: 0.75*width, y: 0.16406*height))
        path.move(to: CGPoint(x: 0.49074*width, y: 0.03906*height))
        path.addLine(to: CGPoint(x: 0.97222*width, y: 0.27344*height))
        path.addLine(to: CGPoint(x: 0.97222*width, y: 0.73438*height))
        path.addLine(to: CGPoint(x: 0.5*width, y: 0.96094*height))
        path.addLine(to: CGPoint(x: 0.02778*width, y: 0.73438*height))
        path.addLine(to: CGPoint(x: 0.02778*width, y: 0.27344*height))
        path.addLine(to: CGPoint(x: 0.49074*width, y: 0.03906*height))
        path.closeSubpath()
        return path
    }
}

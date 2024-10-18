//
//  DiamondShape.swift
//  PokemonTCG
//
//  Created by Duncan Horne on 17/10/2024.
//

import SwiftUI

struct DiamondShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.03509*width, y: 0.25781*height))
        path.addLine(to: CGPoint(x: 0.03509*width, y: 0.72656*height))
        path.addLine(to: CGPoint(x: 0.5*width, y: 0.96094*height))
        path.addLine(to: CGPoint(x: 0.96491*width, y: 0.72656*height))
        path.addLine(to: CGPoint(x: 0.96491*width, y: 0.25781*height))
        path.move(to: CGPoint(x: 0.5*width, y: 0.48438*height))
        path.addLine(to: CGPoint(x: 0.5*width, y: 0.94531*height))
        path.move(to: CGPoint(x: 0.65789*width, y: 0.41406*height))
        path.addLine(to: CGPoint(x: 0.65789*width, y: 0.86719*height))
        path.move(to: CGPoint(x: 0.81579*width, y: 0.78906*height))
        path.addLine(to: CGPoint(x: 0.81579*width, y: 0.33594*height))
        path.move(to: CGPoint(x: 0.5*width, y: 0.65625*height))
        path.addLine(to: CGPoint(x: 0.04386*width, y: 0.42188*height))
        path.move(to: CGPoint(x: 0.5*width, y: 0.80469*height))
        path.addLine(to: CGPoint(x: 0.04386*width, y: 0.57031*height))
        path.move(to: CGPoint(x: 0.20175*width, y: 0.32031*height))
        path.addLine(to: CGPoint(x: 0.63158*width, y: 0.10156*height))
        path.move(to: CGPoint(x: 0.76316*width, y: 0.17969*height))
        path.addLine(to: CGPoint(x: 0.34211*width, y: 0.39844*height))
        path.move(to: CGPoint(x: 0.9386*width, y: 0.25781*height))
        path.addLine(to: CGPoint(x: 0.5*width, y: 0.03125*height))
        path.addLine(to: CGPoint(x: 0.0614*width, y: 0.25781*height))
        path.addLine(to: CGPoint(x: 0.5*width, y: 0.49219*height))
        path.addLine(to: CGPoint(x: 0.9386*width, y: 0.25781*height))
        path.closeSubpath()
        return path
    }
}

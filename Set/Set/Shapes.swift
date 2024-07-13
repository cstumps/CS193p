//
//  Shapes.swift
//  Set
//
//  Created by Jason Hirst on 5/21/24.
//

import SwiftUI

struct Diamond: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)

        let top = CGPoint(x: rect.width / 2,
                          y: center.y - (rect.height / 2))

        let left = CGPoint(x: 0,
                           y: center.y)

        let bottom = CGPoint(x: rect.width / 2,
                             y: center.y + (rect.height / 2))

        let right = CGPoint(x: rect.width,
                            y: center.y)

        var p = Path()

        p.move(to: top)
        p.addLine(to: left)
        p.addLine(to: bottom)
        p.addLine(to: right)
        p.addLine(to: top)

        return p
    }
}

struct Bowtie: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)

        let topLeft = CGPoint(x: 0, y: center.y - (rect.height / 2))
        let topRight = CGPoint(x: rect.width, y: center.y - (rect.height / 2))
        let midLeft = CGPoint(x: center.x - rect.width / 4, y: center.y)
        let midRight = CGPoint(x: center.x + rect.width / 4, y: center.y)
        let bottomLeft = CGPoint(x: 0, y: center.y + (rect.height / 2))
        let bottomRight = CGPoint(x: rect.width, y: center.y + (rect.height / 2))

        var p = Path()

        p.move(to: topLeft)
        p.addLine(to: topRight)
        p.addLine(to: midRight)
        p.addLine(to: bottomRight)
        p.addLine(to: bottomLeft)
        p.addLine(to: midLeft)
        p.addLine(to: topLeft)

        return p
    }
}

extension RoundedRectangle {
    init() {
        self.init(cornerRadius: 20)
    }
}
//
//extension Shape {
//    func flipped() -> ScaledShape<Self> {
//        scale(x: 1, y: -1, anchor: .center)
//    }
//}

//
//  Cardify.swift
//  Set
//
//  Created by Jason Hirst on 6/22/24.
//

import SwiftUI

struct Cardify: ViewModifier, Animatable {
    typealias CardState = SetGame.Card.CardState
    
    var rotation: Double // In degrees
    var state: CardState
    
    var animatableData: Double {
        get { rotation }
        set { rotation = newValue }
    }
    
    init(isFaceUp: Bool, cardState: CardState) {
        rotation = isFaceUp ? 0 : 180
        state = cardState
    }
    
    func body(content: Content) -> some View {
        ZStack {
            let borderColor = borderColor(cardState: state)
            let borderWidth = DrawingConstants.lineWidth + (state != CardState.unselected ? 2 : 0)
            
            let shape = RoundedRectangle(cornerRadius: DrawingConstants.cornerRadius)
            
            if rotation < 90 {
                shape.fill().foregroundColor(.white)
                shape.strokeBorder(lineWidth: borderWidth)
                    .foregroundColor(borderColor)
            } else {
                shape.fill().foregroundColor(.teal)
                shape.strokeBorder(lineWidth: DrawingConstants.lineWidth)
            }
            content.opacity(rotation < 90 ? 1 : 0)
        }
        .rotation3DEffect(Angle.degrees(rotation), axis: (0, 1, 0))
    }
    
    private func borderColor(cardState: CardState) -> Color {
        switch cardState {
        case .matched:
            return Color.yellow
        case .mismatched:
            return Color.orange
        case .selected:
            return Color.pink
        default:
            return Color.black
        }
    }
    
    private struct DrawingConstants {
        static let cornerRadius: CGFloat = 10
        static let lineWidth: CGFloat = 3
    }
    
}

extension View {
    func cardify(isFaceUp: Bool, cardState: SetGame.Card.CardState) -> some View {
        self.modifier(Cardify(isFaceUp: isFaceUp, cardState: cardState))
    }
}

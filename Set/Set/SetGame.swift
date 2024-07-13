//
//  SetGame.swift
//  Set
//
//  Created by Jason Hirst on 5/22/24.
//

import SwiftUI

class SetGame: ObservableObject {
    typealias Game = SetModel<CardShape, CardColor, CardShading>
    typealias Card = SetModel<CardShape, CardColor, CardShading>.Card
    
    @Published private(set) var model: SetModel<CardShape, CardColor, CardShading>
    
    init() {
        model = SetGame.createSetGameModel()
    }

    private static func createSetGameModel() -> Game {
        let model = SetModel(shapes: CardShape.allCases,
                             colors: CardColor.allCases,
                             shades: CardShading.allCases,
                             maxShapesPerCard: 3)
        
        return model
    }
    
    var cards: Array<Card> {
        model.cards
    }
    
    var deck: Array<Card> {
        model.deck
    }
    
    var isMatchPresent: Bool {
        deck.filter({$0.state == .matched}).count > 0
    }
    
    //MARK: - Intents
    func newGame() {
        model = SetGame.createSetGameModel()
    }
    
    func selectCard(_ card: Card) {
        // Leave the last matching pair on the screen
        if cards.count > 3 || card.state != Card.CardState.matched {
            model.selectCard(card)
        }
    }
    
    func deal() {
        model.dealThreeCards()
    }
    
    func flipCard(_ card: Card) {
        model.flipCard(card)
    }
    // MARK: - Enums
    enum CardShape: Int, CaseIterable {
        case diamond, rect, bowtie
        
        var value: some Shape {
            switch self {
            case .diamond: return AnyShape(Diamond())
            case .rect:    return AnyShape(RoundedRectangle())
            case .bowtie:  return AnyShape(Bowtie())
            }
        }
    }
    
    enum CardColor: Int, CaseIterable {
        case blue,  green, purple
        
        var value: Color {
            switch self {
            case .blue:   return Color.blue
            case .green:  return Color.green
            case .purple: return Color.purple
            }
        }
    }
    
    enum CardShading: Int, CaseIterable {
        case empty, semi, full
        
        var value: Double {
            switch self {
            case .empty: return 0.0
            case .semi:  return 0.1
            case .full:  return 1.0
            }
        }
    }
}

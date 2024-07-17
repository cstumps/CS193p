//
//  EmojiMemoryGame.swift
//  Memorize
//
//  Created by Jason Hirst on 4/26/23.
//

import SwiftUI

class EmojiMemoryGame: ObservableObject {
    typealias Card = MemoryGame<String>.Card
    
    @Published private(set) var model: MemoryGame<String>
    
    private var theme: Theme<String>
    private(set) var dealt: Bool = false
  
    init(theme: Theme<String>) {
        self.theme = theme
        model = EmojiMemoryGame.createMemoryGame(theme: theme)
    }
    
    private static func createMemoryGame(theme: Theme<String>) -> MemoryGame<String> {
        let cardSet = theme.returnCardSet()
        
        return MemoryGame<String>(numberOfPairs: theme.numberOfPairs) { index in
            cardSet[ index ]
        }
    }
    
    var name: String {
        return theme.name
    }
    
    var cards: Array<Card> {
        return model.cards
    }
    
    var score:Int {
        return model.score
    }
    
    var color: Color {
        return Color(rgba: theme.color)
    }
    
    // MARK: - Intents
    
    func choose(_ card: Card) {
        model.choose(card)
    }
    
    func shuffle() {
        model.shuffle()
    }
    
    func newGame() {
        model = EmojiMemoryGame.createMemoryGame(theme: theme)
        dealt = false
    }
    
    func deal() {
        dealt = true
    }
}

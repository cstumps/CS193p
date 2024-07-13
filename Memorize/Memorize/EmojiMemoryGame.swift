//
//  EmojiMemoryGame.swift
//  Memorize
//
//  Created by Jason Hirst on 4/26/23.
//

import SwiftUI

class EmojiMemoryGame: ObservableObject {
    typealias Card = MemoryGame<String>.Card
    
    private static var themes = [
        Theme(name: "Animals",
              color: "Green",
              numberOfPairs: 4,
              contentSet: ["🐶","🐱","🐭","🐹","🐰","🦊","🐻","🐼","🐻‍❄️","🐨","🐯","🦁","🐮","🐷","🐽","🐸","🐵","🐔","🐧","🐦","🐤","🐥","🪿","🦆","🐦‍⬛","🦅","🦉","🦇","🐺","🐗","🐴","🦄","🫎"]),
        Theme(name: "Halloween",
              color: "Orange",
              numberOfPairs: 8,
              contentSet: ["🎃","😈","👹","👻","💀","😺","👽","🧟‍♀️","🧛","🧌","🧙‍♂️"]),
        Theme(name: "Vehicles",
              color: "Red",
              numberOfPairs: 10,
              contentSet: ["🚗","🚕","🚙","🚌","🚎","🏎️","🚓","🚑","🚒","🚐","🛻","🚚","🚛","🚜","✈️","🚀","🚁"]),
        Theme(name: "Sports",
              color: "Blue",
              numberOfPairs: 14,
              contentSet: ["⚽️","🏀","🏈","⚾️","🥎","🎾","🏐","🏉","🥏","🎱","🪀","🏓","🥊","🥌"]),
        Theme(name: "Food",
              color: "Yellow",
              contentSet: ["🍏","🍎","🍐","🍊","🍋","🥑","🍌","🍉","🍇","🍓","🫐","🍒","🍑","🥝","🥥","🌮","🍗","🍔","🥨","🌶️","🍿","🍕","🌽"],
              randomNumberOfPairs: true),
        Theme(name: "Plants",
              color: "Violet",
              contentSet: ["🌵","🌲","🌳","🌴","🌱","🌿","☘️","🍀","🪴","🍄","🌹","🥀","🌺","🌻","🌼"])
    ]
    
    @Published private(set) var model: MemoryGame<String>
    private var theme: Theme<String>
  
    init() {
        theme = EmojiMemoryGame.themes[Int.random(in: 0..<EmojiMemoryGame.themes.count)]
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
        switch theme.color {
        case "Green":
            return Color.green
        case "Orange":
            return Color.orange
        case "Red":
            return Color.red
        case "Blue":
            return Color.blue
        case "Yellow":
            return Color.yellow
        case "Violet":
            return Color.purple
        default:
            return Color.red
        }
    }
    
    // MARK: - Intents
    
    func choose(_ card: Card) {
        model.choose(card)
    }
    
    func shuffle() {
        model.shuffle()
    }
    
    func newGame() {
        theme = EmojiMemoryGame.themes[Int.random(in: 0..<EmojiMemoryGame.themes.count)]
        model = EmojiMemoryGame.createMemoryGame(theme: theme)
    }
}

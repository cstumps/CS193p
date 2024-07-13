//
//  SetModel.swift
//  Set
//
//  Created by Jason Hirst on 5/22/24.
//

import Foundation

struct SetModel<Shape, Color, Shade> where Shape: RawRepresentable, Shape.RawValue: Hashable,
                                           Color: RawRepresentable, Color.RawValue: Hashable,
                                           Shade: RawRepresentable, Shade.RawValue: Hashable {
    
    var deck: [Card]
    
    // An array of cards that have a position value of not nil, sorted.
    var cards: [Card] {
        deck.filter({ $0.boardPosition != nil }).sorted { $0.boardPosition! < $1.boardPosition! }
    }
    
    var matchedCardIndicies: [Int]? {
        deck.indices.filter({ deck[$0].state == .matched || deck[$0].state == .mismatched }).threeOnly
    }
    
    private var nextCardIndex: Int? {
        deck.indices.filter({ deck[$0].boardPosition == nil && deck[$0].state != .discarded }).first
    }
    
    private var selectedCardIndicies: [Int]? {
        deck.indices.filter({ deck[$0].state == .selected }).threeOnly
    }
    
    struct Card: Identifiable {
        let shape: Shape
        let color: Color
        let shade: Shade
        let count: Int
        let id: Int
        
        var boardPosition: Int?
        var state: CardState = .unselected
        var isFaceUp = false
        
        var isMatched = false

        enum CardState {
            case unselected, selected, matched, mismatched, discarded
            
            mutating func toggle() {
                self = (self == .unselected ? .selected : .unselected)
            }
        }
    }
    
    init(shapes: [Shape], colors: [Color], shades: [Shade], maxShapesPerCard: Int) {
        var id = 0
        deck = []
        
        for shape in shapes {
            for color in colors {
                for shade in shades {
                    for i in 1...maxShapesPerCard {
                        deck.append(Card(shape: shape, color: color, shade: shade, count: i, id: id))
                        id += 1
                    }
                }
            }
        }

        // Deal out the first 12 cards
        //deck.shuffle()
        
        for i in 0..<min(deck.count, 12) {
            deck[i].boardPosition = i
        }
    }

    mutating func flipCard(_ card: Card) {
        if let chosenIndex = deck.firstIndex(where: { $0.id == card.id }) {
            deck[chosenIndex].isFaceUp.toggle()
        }
    }
    
    mutating func dealThreeCards() {
        if let matchedSet = matchedCardIndicies,
           deck[matchedSet.first!].state == .matched
        {
            replaceAndDiscard(cardIndicesToReplace: matchedSet)
        } else {
            for _ in 0..<3 {
                if let nextCard = nextCardIndex {
                    deck[nextCard].boardPosition = (cards.max(by: {$0.boardPosition! < $1.boardPosition!})?.boardPosition ?? 0) + 1
                }
            }
        }
    }
    
    mutating func selectCard(_ card: Card) {
        if let chosenIndex = deck.firstIndex(where: { $0.id == card.id })
        {
            if let matchedSet = matchedCardIndicies {
                // For matched sets, replace with new cards and discard
                if deck[matchedSet.first!].state == .matched {
                    //replaceAndDiscard(cardIndicesToReplace: matchedSet)
                    for cardIndex in matchedSet {
                        deck[cardIndex].state = .discarded
                        deck[cardIndex].boardPosition = nil
                    }
                } else {
                    // For mismatched sets, just de-select them
                    for cardIndex in matchedSet {
                        deck[cardIndex].state = .unselected
                    }
                }
            }

            deck[chosenIndex].state.toggle() // Select the chosen card
            
            // Executes if exactly three cards selected and flags cards as matched or mismatched set
            if let potentialSet = selectedCardIndicies {
                let isValidSet = isSet(deck[potentialSet[0]], deck[potentialSet[1]], deck[potentialSet[2]])
                
                for cardIndex in potentialSet {
                    deck[cardIndex].state = (isValidSet ? .matched : .mismatched)
                }
            }
        }
    }
    
    // Detemins if three passed in cards constitute a set according to the rules
    private func isSet(_ first: Card, _ second: Card, _ third: Card) -> Bool {
        let shapes: Set = [first.shape.rawValue, second.shape.rawValue, third.shape.rawValue]
        let colors: Set = [first.color.rawValue, second.color.rawValue, third.color.rawValue]
        let shades: Set = [first.shade.rawValue, second.shade.rawValue, third.shade.rawValue]
        let counts: Set = [first.count, second.count, third.count]
        
        return (shapes.count != 2 && colors.count != 2 && shades.count != 2 && counts.count != 2)
    }
    
    private mutating func replaceAndDiscard(cardIndicesToReplace: [Int]) {
        for cardIndex in cardIndicesToReplace {
            if let nextCard = nextCardIndex {
                deck[nextCard].boardPosition = deck[cardIndex].boardPosition
            }
            
            deck[cardIndex].boardPosition = nil
            deck[cardIndex].state = .discarded
        }
    }
}

extension Array {
    var threeOnly: [Element]? {
        count == 3 ? self : nil
    }
}

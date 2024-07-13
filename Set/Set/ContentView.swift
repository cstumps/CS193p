//
//  ContentView.swift
//  Set
//
//  Created by Jason Hirst on 5/21/24.
//

/*
 Outstanding issues: Probably not worth fixing, we've gone a bit beyond the expectations of the assignment I think
    Deselection of card happens at different times depending on if you press deal or select a different
    card when there is a match on the board.
 
    Cards that are dealt out as replacements, fly to game board behind existing cards for some reason.
 
    Also noticed that after new cards are dealt out to the board, if new game is pressed the new cards
    fly back underneath cards that have been on the board longer.
 
    On deck deal, cards scale up and it's a bit noticible.  Without this transistion though we don't
    get in order dealing out of the deck so I think we're stuck with this unless we want to write our
    own transistion.
 
    The animations for match and mismatch aren't great but they work.  Either I designed this wrong / without
    animation in mind or I don't have a great grasp of the animataion system yet.
 
    The content view here is overly complex.  It probably would have made more sense to add additional
    complexity to me model or view model to support the animations and reduced the complexity here.
 
    Maybe watch the 2023 videos on animation.
 */

import SwiftUI

struct ContentView: View {
    @ObservedObject var game: SetGame
    
    @Namespace private var dealingNamespace

    var body: some View {
        VStack {
            Text("Solo Set").font(.title)
            gameBody
            HStack {
                Spacer()
                drawDeck
                Spacer()
                discardPile
                Spacer()
            }
            .padding(.vertical)
            Button("New Game") {
                dealAnimation(startingDelay: 0.0, game.cards.filter({dealt.contains($0.id)}).reversed(), {dealt.remove($0.id)}) {
                    withAnimation { // This animates the folding of the discard pile back into the deck
                        discarded = []
                        dealt = []
                        game.newGame()
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    var gameBody: some View {
        AspectVGrid(items: game.cards, aspectRatio: CardConstants.aspectRatio) { card in
            if isUndealt(card) || isDiscarded(card) {
                Color.clear
            } else {
                CardView(card: card)
                    .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                    .padding(4)
                    .transition(.asymmetric(insertion: .identity, removal: .scale))
                    //.zIndex(-Double(game.deck.firstIndex(where: {$0.id == card.id }) ?? 0))
                    .onTapGesture {
                        if game.isMatchPresent {
                            dealAnimation(startingDelay: 0.0, game.cards.filter({$0.state == .matched}), discard) {
                                game.selectCard(card)
                            }
                        } else {
                            game.selectCard(card)
                        }
                    }
            }
        }
    }
    
    var drawDeck: some View {
        ZStack {
            ForEach(game.deck.filter(isUndealt)) { card in
                CardView(card: card)
                    .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                    .transition(.asymmetric(insertion: .identity, removal: .scale))
                    .zIndex(-Double(game.deck.firstIndex(where: {$0.id == card.id }) ?? 0))
            }
        }
        .frame(width: CardConstants.undealtWidth, height: CardConstants.undealtHeight)
        .onTapGesture {
            var animationDelay = 0.0
            
            // We need to handle discards before dealing new cards otherwise the discards
            // will no longer be part of the view we wish to animate
            dealAnimation(startingDelay: animationDelay, game.cards.filter({$0.state == .matched}), discard)

            // Deal three cards if the board has already been dealt out and the deck is touched
            if !dealt.isEmpty {
                game.deal()
                animationDelay = CardConstants.animationStartDelay // Stagger the discard and deal animations
            }
            
            dealAnimation(startingDelay: animationDelay, game.cards.filter(isUndealt), deal)
        }
    }
    
    var discardPile: some View {
        ZStack {
            ForEach(game.deck.filter(isDiscarded)) { card in
                CardView(card: card)
                    .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                    .transition(.asymmetric(insertion: .identity, removal: .identity))
            }
        }
        .frame(width: CardConstants.undealtWidth, height: CardConstants.undealtHeight)
    }
    
    @State private var dealt = Set<Int>()
    @State private var discarded = Set<Int>()
    
    private func deal(_ card: SetGame.Card) {
        dealt.insert(card.id)
    }
    
    private func isUndealt(_ card: SetGame.Card) -> Bool {
        !dealt.contains(card.id)
    }
    
    private func discard(_ card: SetGame.Card) {
        discarded.insert(card.id)
    }
    
    private func isDiscarded(_ card: SetGame.Card) -> Bool {
        discarded.contains(card.id)
    }
    
    private func dealAnimation(startingDelay: Double, _ cards: [SetGame.Card], _ setFunc: (SetGame.Card) -> Void) {
        dealAnimation(startingDelay: startingDelay, cards, setFunc, nil)
    }
    
    private func dealAnimation(startingDelay: Double, _ cards: [SetGame.Card], _ setFunc: (SetGame.Card) -> Void, _ compFunc: (() -> Void)?) {
        let weight = (Double(cards.count) / CardConstants.cardCountWeight)
        var delay = 0.0
        
        for (index, card) in cards.enumerated() {
            delay = Double(index) * (CardConstants.totalDealDuration * weight / Double(cards.count))
            
            // Deal the cards
            withAnimation(.easeOut(duration: CardConstants.dealDuration).delay(startingDelay + delay)) {
                setFunc(card)
                
                // Flip the cards over using same delays
                withAnimation(.linear(duration: CardConstants.dealDuration).delay(startingDelay + delay)) {
                    if !card.isFaceUp {
                        game.flipCard(card)
                    }
                }
            } completion: {
                if index == (cards.count - 1), // Last card and completion function specified
                    let finishStep = compFunc {
                    finishStep()
                }
            }
        }
    }
    
    private struct CardConstants {
        static let aspectRatio: CGFloat = 2/3
        static let undealtHeight: CGFloat = 90
        static let undealtWidth: CGFloat = undealtHeight * aspectRatio
        static let dealDuration: Double = 0.5
        static let totalDealDuration: Double = 2.0
        static let cardCountWeight: Double = 12.0
        static let animationStartDelay: Double = 0.2
    }
}

struct CardView: View {
    let card: SetGame.Card
    
    @State private var rotation: CGFloat = 0
    @State private var scale: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            // Draw the card content
            VStack {
                ForEach(0..<card.count, id:\.self) { _ in
                    ZStack {
                        let shape = card.shape.value
                            
                        shape.opacity(card.shade.value)
                        shape.stroke()
                    }
                    .frame(width: geometry.size.width / 2, height: geometry.size.height / 6)
                    .foregroundColor(card.color.value)
                    .scaleEffect(1 + scale)
                    .rotationEffect(Angle.degrees(rotation))
                    .onChange(of: card.state) { oldValue, newValue  in
                        if newValue == .matched {
                            withAnimation(.easeInOut.repeatForever()) {
                                scale = 0.2
                            }
                        } else {
                            withAnimation {
                                scale = 0.0
                            }
                        }
                        
                        if newValue == .mismatched {
                            withAnimation(.smooth().repeatCount(1, autoreverses: false)) {
                                rotation = 360
                            }
                        } else {
                            withAnimation {
                                rotation = 0
                            }
                        }
                    }
                }
            }
            .cardify(isFaceUp: card.isFaceUp, cardState: card.state)
        }
    }
}

#Preview {
    Group {
        let game = SetGame()
        ContentView(game: game)
    }
}

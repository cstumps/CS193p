//
//  MemorizeApp.swift
//  Memorize
//
//  Created by Jason Hirst on 4/23/23.
//

import SwiftUI

@main
struct MemorizeApp: App {
    private let game = EmojiMemoryGame()
    
    var body: some Scene {
        WindowGroup {
            EmojiMemoryGameView(game: game)
        }
    }
}

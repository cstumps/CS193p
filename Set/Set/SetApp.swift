//
//  SetApp.swift
//  Set
//
//  Created by Jason Hirst on 5/21/24.
//

import SwiftUI

@main
struct SetApp: App {
    var body: some Scene {
        WindowGroup {
            let game = SetGame()
            
            ContentView(game: game)
        }
    }
}

//
//  ThemeStore.swift
//  Memorize
//
//  Created by Jason Hirst on 7/13/24.
//

import SwiftUI

class ThemeStore: ObservableObject {
    let name: String
    
    @Published var themes: [Theme<String>] = ThemeStore.builtins

    init(named name: String) {
        self.name = name
        
//        if themes.isEmpty {
//            themes = ThemeStore.builtins
//        }
    }
    
    static var builtins: [Theme<String>] { [
        Theme(name: "Animals",
              color: RGBA(color: .green),
              numberOfPairs: 4,
              contentSet: ["🐶","🐱","🐭","🐹","🐰","🦊","🐻","🐼","🐻‍❄️","🐨","🐯","🦁","🐮","🐷","🐽","🐸","🐵","🐔","🐧","🐦","🐤","🐥","🪿","🦆","🐦‍⬛","🦅","🦉","🦇","🐺","🐗","🐴","🦄","🫎"]),
        Theme(name: "Halloween",
              color: RGBA(color: .orange),
              numberOfPairs: 8,
              contentSet: ["🎃","😈","👹","👻","💀","😺","👽","🧟‍♀️","🧛","🧌","🧙‍♂️"]),
        Theme(name: "Vehicles",
              color: RGBA(color: .red),
              numberOfPairs: 10,
              contentSet: ["🚗","🚕","🚙","🚌","🚎","🏎️","🚓","🚑","🚒","🚐","🛻","🚚","🚛","🚜","✈️","🚀","🚁"]),
        Theme(name: "Sports",
              color: RGBA(color: .blue),
              numberOfPairs: 14,
              contentSet: ["⚽️","🏀","🏈","⚾️","🥎","🎾","🏐","🏉","🥏","🎱","🪀","🏓","🥊","🥌"]),
        Theme(name: "Food",
              color: RGBA(color: .yellow),
              contentSet: ["🍏","🍎","🍐","🍊","🍋","🥑","🍌","🍉","🍇","🍓","🫐","🍒","🍑","🥝","🥥","🌮","🍗","🍔","🥨","🌶️","🍿","🍕","🌽"],
              randomNumberOfPairs: true),
        Theme(name: "Plants",
              color: RGBA(color: .purple),
              contentSet: ["🌵","🌲","🌳","🌴","🌱","🌿","☘️","🍀","🪴","🍄","🌹","🥀","🌺","🌻","🌼"])
    ]}
}



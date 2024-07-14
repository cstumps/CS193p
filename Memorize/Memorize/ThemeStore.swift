//
//  ThemeStore.swift
//  Memorize
//
//  Created by Jason Hirst on 7/13/24.
//

import SwiftUI

class ThemeStore: ObservableObject {
    let name: String
    
    @Published var themes: [Theme<String, Color>] = ThemeStore.builtins

    init(named name: String) {
        self.name = name
        
//        if themes.isEmpty {
//            themes = ThemeStore.builtins
//        }
    }
    
    static var builtins: [Theme<String, Color>] { [
        Theme(name: "Animals",
              color: Color.green,
              numberOfPairs: 4,
              contentSet: ["🐶","🐱","🐭","🐹","🐰","🦊","🐻","🐼","🐻‍❄️","🐨","🐯","🦁","🐮","🐷","🐽","🐸","🐵","🐔","🐧","🐦","🐤","🐥","🪿","🦆","🐦‍⬛","🦅","🦉","🦇","🐺","🐗","🐴","🦄","🫎"]),
        Theme(name: "Halloween",
              color: Color.orange,
              numberOfPairs: 8,
              contentSet: ["🎃","😈","👹","👻","💀","😺","👽","🧟‍♀️","🧛","🧌","🧙‍♂️"]),
        Theme(name: "Vehicles",
              color: Color.red,
              numberOfPairs: 10,
              contentSet: ["🚗","🚕","🚙","🚌","🚎","🏎️","🚓","🚑","🚒","🚐","🛻","🚚","🚛","🚜","✈️","🚀","🚁"]),
        Theme(name: "Sports",
              color: Color.blue,
              numberOfPairs: 14,
              contentSet: ["⚽️","🏀","🏈","⚾️","🥎","🎾","🏐","🏉","🥏","🎱","🪀","🏓","🥊","🥌"]),
        Theme(name: "Food",
              color: Color.yellow,
              contentSet: ["🍏","🍎","🍐","🍊","🍋","🥑","🍌","🍉","🍇","🍓","🫐","🍒","🍑","🥝","🥥","🌮","🍗","🍔","🥨","🌶️","🍿","🍕","🌽"],
              randomNumberOfPairs: true),
        Theme(name: "Plants",
              color: Color.purple,
              contentSet: ["🌵","🌲","🌳","🌴","🌱","🌿","☘️","🍀","🪴","🍄","🌹","🥀","🌺","🌻","🌼"])
    ]}
}



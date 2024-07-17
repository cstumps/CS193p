//
//  ThemeStore.swift
//  Memorize
//
//  Created by Jason Hirst on 7/13/24.
//

import SwiftUI

extension UserDefaults {
    func themes(forKey key: String) -> [Theme<String>] {
        if let jsonData = data(forKey: key),
           let decodedThemes = try? JSONDecoder().decode([Theme<String>].self, from: jsonData) {
            return decodedThemes
        } else {
            return []
        }
    }
    
    func set(_ themes: [Theme<String>], forKey key: String) {
        let data = try? JSONEncoder().encode(themes)
        set(data, forKey: key)
    }
}

class ThemeStore: ObservableObject, Identifiable {
    let name: String
    
    var id: String { name }
    
    private var userDefaultsKey: String { "ThemeStore:" + name }
    
    var themes: [Theme<String>] {
        get {
            UserDefaults.standard.themes(forKey: userDefaultsKey)
        }
        set {
            UserDefaults.standard.set(newValue.isEmpty ? ThemeStore.builtins : newValue, forKey: userDefaultsKey)
            objectWillChange.send()
        }
    }

    init(named name: String) {
        self.name = name
        
        if themes.isEmpty {
            themes = ThemeStore.builtins
        }
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
    
    func append(_ theme: Theme<String>) {
        if let index = themes.firstIndex(where: { $0.id == theme.id }) {
            if themes.count == 1 {
                themes = [theme]
            } else {
                themes.remove(at: index)
            }
        } else {
            themes.append(theme)
        }
    }
}

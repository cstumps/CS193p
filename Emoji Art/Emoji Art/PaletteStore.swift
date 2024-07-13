//
//  PaletteStore.swift
//  Emoji Art
//
//  Created by Jason Hirst on 6/28/24.
//

import SwiftUI

extension UserDefaults {
    func palettes(forKey key: String) -> [Palette] {
        if let jsonData = data(forKey: key),
           let decodedPalettes = try? JSONDecoder().decode([Palette].self, from: jsonData) {
            return decodedPalettes
        } else {
            return []
        }
    }
    
    func set(_ palettes: [Palette], forKey key: String) {
        let data = try? JSONEncoder().encode(palettes)
        set(data, forKey: key)
    }
}

// This is done in an extension to illustrate that you can add protocol conformance in
// an extension.
extension PaletteStore: Equatable, Hashable {
    // To conform to equatable
    static func == (lhs: PaletteStore, rhs: PaletteStore) -> Bool {
        lhs.name == rhs.name
    }
    
    // To conform to hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}

class PaletteStore: ObservableObject, Identifiable {
    let name: String
    
    // We do this because if we didn't we could have two PaletteStores with the same name but different pointers
    // (how they are identifable) and they would overwrite each other in the settings.  We need to uniquely id
    // instances of the PaletteStore by name so different instances of hte same class name are considered the same
    // thing.
    var id: String { name }
    
    private var userDefaultsKey: String { "PaletteStore:" + name }
    
    // He intentionally didn't make this private to show what it's like when your view has free reign to edit the model
    var palettes: [Palette] {
        get {
            UserDefaults.standard.palettes(forKey: userDefaultsKey) // Palettes function provided by our extension
        }
        set {
            // Originally this variable was @Published so the view knew when it had been updated.
            // Since we can't have a published variable be computed, we have to indicate the change
            // in value ourselves by calling 'send' as seen here.
            if !newValue.isEmpty {
                UserDefaults.standard.set(newValue, forKey: userDefaultsKey)
                objectWillChange.send() // ObservableObject protocol provides this
            }
        }
    }
    
    init(named name: String) {
        self.name = name
        
        if palettes.isEmpty {
            palettes = Palette.builtins
            
            // Should never happen
            if palettes.isEmpty {
                palettes = [Palette(name: "Warning", emojis: "⚠️")]
            }
        }
    }
    
    @Published private var _cursorIndex = 0
    
    var cursorIndex: Int {
        get { boundsCheckedPaletteIndex(_cursorIndex) }
        set { _cursorIndex = boundsCheckedPaletteIndex(newValue) }
    }
    
    private func boundsCheckedPaletteIndex(_ index: Int) -> Int {
        var index = index % palettes.count
        
        if index < 0 {
            index += palettes.count
        }
        
        return index
    }
    
    // MARK: - Adding Palettes
    
    /*
     These functions are the recommende way to add Palettes to the PaletteStore
     since they try to avoid duplication of Identifiable-ly identical Palettes
     by first removing/replacing any Palette with the same id that is already in
     Palettes. It does not "remedy" existing duplication, it just does not "cause"
     new duplication
     */
    
    func insert(_ palette: Palette, at insertionIndex: Int? = nil) { // "at" default is cursorIndex
        let insertionIndex = boundsCheckedPaletteIndex(insertionIndex ?? cursorIndex)
        
        if let index = palettes.firstIndex(where: { $0.id == palette.id }) {
            palettes.move(fromOffsets: IndexSet([index]), toOffset: insertionIndex)
            palettes.replaceSubrange(insertionIndex...insertionIndex, with: [palette])
        } else {
            palettes.insert(palette, at: insertionIndex)
        }
    }
    
    func insert(name: String, emojis: String, at index: Int? = nil) {
        insert(Palette(name: name, emojis: emojis), at: index)
    }
    
    func append(_ palette: Palette) { // At end of palettes
        if let index = palettes.firstIndex(where: { $0.id == palette.id }) {
            if palettes.count == 1 {
                palettes = [palette]
            } else {
                palettes.remove(at: index)
            }
        }
    }
}

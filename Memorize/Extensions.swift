//
//  Extensions.swift
//  Memorize
//
//  Created by Jason Hirst on 7/14/24.
//

import SwiftUI

struct RGBA: Codable, Equatable, Hashable {
    let red: Double
    let green: Double
    let blue: Double
    let alpha: Double
}

extension Color {
    init(rgba: RGBA) {
        self.init(.sRGB, red: rgba.red, green: rgba.green, blue: rgba.blue, opacity: rgba.alpha)
    }
}

extension RGBA {
    init(color: Color) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        UIColor(color).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        self.init(red: Double(red), green: Double(green), blue: Double(blue), alpha: Double(alpha))
    }
}

extension UUID: Identifiable {
    public var id: String {
        self.uuidString
    }
}

extension String {
    mutating func remove(_ ch: Character) {
        removeAll(where: { $0 == ch })
    }
    
    // Removes any duplicate characters
    // Preserves the order of the characters
    var uniqued: String {
        // Not super efficient
        // Would only want to use it on small-ish strings and we wouldn't want
        // to call it in a tight loop.
        reduce(into: "") { sofar, element in
            if !sofar.contains(element) {
                sofar.append(element)
            }
        }
    }
}

extension Character {
    var isEmoji: Bool {
        // Swift does not have a way to ask if a Character isEmoji
        // but it does let us check to see if our component scalars isEmoji
        // unfortunately unicode allows certain scalars (like 1)
        // to be modified by another scalar to become emoji (e.g. 1️⃣)
        // so the scalar "1" will report isEmoji = true
        // so we can't just check to see if the first scalar isEmoji
        // the quick and dirty here is to see if the scalar is at least the first true emoji we know of
        // (the start of the "miscellaneous items" section)
        // or check to see if this is a multiple scalar unicode sequence
        // (e.g. a 1 with a unicode modifier to force it to be presented as emoji 1️⃣)
        if let firstScalar = unicodeScalars.first, firstScalar.properties.isEmoji {
            return (firstScalar.value >= 0x238d || unicodeScalars.count > 1)
        } else {
            return false
        }
    }
}

extension Array where Element: Hashable {
    func unique() -> [Element] {
        var seen = Set<Element>()
        
        return self.compactMap { element in
            guard !seen.contains(element)
                else { return nil }
            
            seen.insert(element)
            return element
        }
    }
}

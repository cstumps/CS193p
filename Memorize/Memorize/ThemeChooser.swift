//
//  ThemeChooser.swift
//  Memorize
//
//  Created by Jason Hirst on 7/13/24.
//

import SwiftUI

struct ThemeChooser: View {
    @ObservedObject var store: ThemeStore
    
    var body: some View {
        NavigationStack {
            themeList
                .scrollContentBackground(.hidden)
                .background(Color.white)
                .navigationDestination(for: Theme<String, Color>.ID.self) { themeId in
                    if let index = store.themes.firstIndex(where: { $0.id == themeId }) {
                        EmojiMemoryGameView(game: EmojiMemoryGame(theme: store.themes[index]))
                            .navigationBarTitleDisplayMode(.inline)
                    }
                }
                .navigationTitle("Themes")
                .toolbar {
                    Button {
                        
                    } label: {
                        Image(systemName: "plus")
                    }
                }
        }
    } // End body
    
    var themeList: some View {
        List {
            ForEach(store.themes) { theme in
                NavigationLink(value: theme.id) {
                    VStack(alignment: .leading) {
                        Text(theme.name)
                            .font(.title)
                            .foregroundStyle(theme.color)
                        HStack {
                            Text(theme.numberOfPairs == theme.contentSet.count ? "All of" : "\(theme.numberOfPairs) pairs of")
                            Text(theme.contentSet.joined()).lineLimit(1)
                        }
                    }
                }
            }
        }
    } // End themeList
}

#Preview {
    ThemeChooser(store: ThemeStore(named: "Preview"))
}

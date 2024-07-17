//
//  ThemeChooser.swift
//  Memorize
//
//  Created by Jason Hirst on 7/13/24.
//

import SwiftUI

/*
 I had implemented the dictionary to track running games for the extra credit however the dealing
 animation doesnt' work right with it.  Rather than disabling the animation, I commented out
 the game tracking.
 */

struct ThemeChooser: View {
    @ObservedObject var store: ThemeStore
    
    @State private var selectedId: Theme<String>.ID?
    //@State private var runningGames: Dictionary<Theme<String>.ID, EmojiMemoryGame> = [:]
    
    var body: some View {
        NavigationStack {
            themeList
                .scrollContentBackground(.hidden)
                .background(Color.white)
                .sheet(item: $selectedId) { id in
                    if let index = store.themes.firstIndex(where: { $0.id == id }) {
                        ThemeEditor(theme: $store.themes[index])
                    }
                }
                .navigationTitle("Themes")
                .navigationDestination(for: Theme<String>.ID.self) { themeId in
                    startGame(withThemeId: themeId)
                }
                .toolbar {
                    addButton
                }
        }

    }
    
    var themeList: some View {
        List {
            ForEach(store.themes) { theme in
                ThemeListItem(theme: theme)
                    .tag(theme)
                    .swipeActions(edge: .leading) {
                        Button("Edit", systemImage: "pencil") {
                            selectedId = theme.id
                        }.tint(.blue)
                    }
            }
            .onDelete { indexSet in
                withAnimation {
                    store.themes.remove(atOffsets: indexSet)
                }
            }
            .onMove { indexSet, newOffset in
                store.themes.move(fromOffsets: indexSet, toOffset: newOffset)
            }
        }
    }
    
    var addButton: some View {
        Button {
            let newTheme = Theme<String>(name: "", color: RGBA(color: .black), contentSet: ["😀"])
            
            store.append(newTheme)
            selectedId = newTheme.id
        } label: {
            Image(systemName: "plus")
        }
    }
    
    @ViewBuilder
    private func startGame(withThemeId id: Theme<String>.ID) -> some View {
        if let index = store.themes.firstIndex(where: { $0.id == id }) {
            EmojiMemoryGameView(game: EmojiMemoryGame(theme: store.themes[index]))
                .navigationBarTitleDisplayMode(.inline)
            // If this game is already being played, return to it
//            if let game = runningGames[id] {
//                EmojiMemoryGameView(game: game)
//                    .navigationBarTitleDisplayMode(.inline)
//            } else {
//                let game = EmojiMemoryGame(theme: store.themes[index])
//                
//                EmojiMemoryGameView(game: game)
//                    .navigationBarTitleDisplayMode(.inline)
//                    .onAppear() {
//                        runningGames[id] = game
//                    }
//            }
        }
    }
}

struct ThemeListItem: View {
    var theme: Theme<String>
    
    var body: some View {
        NavigationLink(value: theme.id) {
            VStack(alignment: .leading) {
                Text(theme.name)
                    .font(.title)
                    .foregroundStyle(Color(rgba: theme.color))
                HStack {
                    Text(theme.numberOfPairs == theme.contentSet.count ? "All of" : "\(theme.numberOfPairs) pairs of")
                    Text(theme.contentSet.joined()).lineLimit(1)
                }
            }
        }
    }
}

#Preview {
    ThemeChooser(store: ThemeStore(named: "Preview"))
}

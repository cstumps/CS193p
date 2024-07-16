//
//  ThemeChooser.swift
//  Memorize
//
//  Created by Jason Hirst on 7/13/24.
//

import SwiftUI

struct ThemeChooser: View {
    @ObservedObject var store: ThemeStore
    
    @State private var selectedId: Theme<String>.ID?
    
    var body: some View {
        NavigationStack {
            List(store.themes) { theme in
                ThemeListItem(theme: theme)
                    .tag(theme)
                    .swipeActions(edge: .leading) {
                        Button("Edit", systemImage: "pencil") {
                            selectedId = theme.id
                        }.tint(.blue)
                    }
            }
            .scrollContentBackground(.hidden)
            .background(Color.white)
            .sheet(item: $selectedId) { id in
                if let index = store.themes.firstIndex(where: { $0.id == id }) {
                    ThemeEditor(theme: $store.themes[index])
                }
            }
            .navigationTitle("Themes")
            .navigationDestination(for: Theme<String>.ID.self) { themeId in
                if let index = store.themes.firstIndex(where: { $0.id == themeId }) {
                    EmojiMemoryGameView(game: EmojiMemoryGame(theme: store.themes[index]))
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
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

//struct ThemeChooser: View {
//    @ObservedObject var store: ThemeStore
//    
//    @State private var showThemeEditor = false
//    @State private var selectedId: Theme<String>.ID?
//    
//    var body: some View {
//        NavigationStack {
//            themeList
//            //ThemeList(store: store, selectedId: self.$selectedId)
//                .scrollContentBackground(.hidden)
//                .background(Color.white)
//                .navigationDestination(for: Theme<String>.ID.self) { themeId in
//                    if let index = store.themes.firstIndex(where: { $0.id == themeId }) {
//                        EmojiMemoryGameView(game: EmojiMemoryGame(theme: store.themes[index]))
//                            .navigationBarTitleDisplayMode(.inline)
//                    }
//                }
//                .navigationTitle("Themes")
//                .toolbar {
//                    Button {
//                        
//                    } label: {
//                        Image(systemName: "plus")
//                    }
//                }
//        }
//    } // End body
//    
//    var themeList: some View {
//        List {
//            ForEach(store.themes) { theme in
//                NavigationLink(value: theme.id) {
//                    VStack(alignment: .leading) {
//                        Text(theme.name)
//                            .font(.title)
//                            .foregroundStyle(Color(rgba: theme.color))
//                        HStack {
//                            Text(theme.numberOfPairs == theme.contentSet.count ? "All of" : "\(theme.numberOfPairs) pairs of")
//                            Text(theme.contentSet.joined()).lineLimit(1)
//                        }
//                    }
//                    .swipeActions(edge: .leading) {
//                        Button("Edit", systemImage: "pencil") {
//                            selectedId = theme.id
//                            showThemeEditor = true
//                        }.tint(.blue)
//                    }
//                }
//            }
//            .onDelete { indexSet in
//                withAnimation {
//                    store.themes.remove(atOffsets: indexSet)
//                }
//            }
//            .onMove { indexSet, newOffset in
//                store.themes.move(fromOffsets: indexSet, toOffset: newOffset)
//            }
////            .onChange(of: selectedId) {
////                if let id = selectedId {
////                    print("\(id)")
////                }
////            }
//        }
//        .sheet(isPresented: $showThemeEditor) {
//            if let index = store.themes.firstIndex(where: { $0.id == selectedId }) {
//                ThemeEditor(theme: $store.themes[index])
//            }
//        }
//    } // End themeList
//}



#Preview {
    ThemeChooser(store: ThemeStore(named: "Preview"))
}

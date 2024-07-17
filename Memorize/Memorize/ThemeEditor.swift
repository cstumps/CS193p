//
//  ThemeEditor.swift
//  Memorize
//
//  Created by Jason Hirst on 7/14/24.
//

import SwiftUI

// The assignment suggests creating convience functions to hand rgba conversions for the view so it
// doesn't need to be aware of that construct.  Based on how I implemented my views (poorly), this
// seems to me to add additional complexity and so I will omit that part.

struct ThemeEditor: View {
    @Binding var theme: Theme<String>
    
    @State private var themeColor: Color
    @State private var emojisToAdd: String = ""
    
    @FocusState private var focused: Bool
    
    init(theme: Binding<Theme<String>>) {
        _theme = theme
        themeColor = Color(rgba: theme.wrappedValue.color)
    }
    
    var body: some View {
        Form {
            Section {
                nameAndColor
            }
            Section {
                VStack {
                    removeEmojis
                    addEmojis
                    changePairs
                }
            } header: {
                HStack {
                    Text("Emojis").font(.headline)
                    Spacer()
                    Text("Tap to include or exclude")
                }
            }
            if theme.removedContent.count != 0 {
                Section {
                    removedEmojis
                } header: {
                    Text("Previously removed Emojis, tap to re-add")
                }
            }
        }
        .onAppear {
            if theme.name.isEmpty {
                focused = true
            }
        }
    }
    
    var nameAndColor: some View {
        HStack {
            TextField("Name", text: $theme.name)
                .font(.title)
                .foregroundStyle(Color(rgba: theme.color))
                .focused($focused, equals: true)
            Spacer()
            ColorPicker("Colors", selection: $themeColor)
                .labelsHidden()
                .onChange(of: themeColor) { _, newColor in
                    theme.color = RGBA(color: newColor)
                }
        }
    }
    
    var removeEmojis: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))]) {
            ForEach(theme.contentSet, id: \.self) { emoji in
                Text(emoji)
                    .font(.title)
                    .onTapGesture {
                        withAnimation {
                            theme.removeContent(emoji)
                        }
                    }
            }
        }
    }
    
    var removedEmojis: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))]) {
            ForEach(theme.removedContent, id: \.self) { emoji in
                Text(emoji)
                    .font(.title)
                    .onTapGesture {
                        withAnimation {
                            theme.addContent(emoji)
                        }
                    }
            }
        }
    }
    
    var addEmojis: some View {
        TextField("Tap here to add Emojis", text: $emojisToAdd)
            .tint(.clear)
            .font(.headline)
            .textFieldStyle(.roundedBorder)
            .padding(.top)
            .onChange(of: emojisToAdd) { _, newEmoji in
                if let emoji = newEmoji.first {
                    if emoji.isEmoji && !theme.contentSet.contains(newEmoji) {
                        theme.addContent(newEmoji)
                    }
                }
                emojisToAdd = ""
            }
    }
    
    var changePairs: some View {
        Stepper {
            Text("\(theme.numberOfPairs) Pairs")
        } onIncrement: {
            theme.addPair()
        } onDecrement: {
            theme.removePair()
        }
    }
}

#Preview {
    @State var theme = ThemeStore(named: "Preview").themes.first!
    return ThemeEditor(theme: $theme)
}

//
//  ThemeEditor.swift
//  Memorize
//
//  Created by Jason Hirst on 7/14/24.
//

import SwiftUI

// View doesn't need to know about RGBA format.  Create convience functions in ViewModel to handle that for it.

// Need to unique emoji list and maybe confirm a character is a emoji or not

struct ThemeEditor: View {
    @Binding var theme: Theme<String>
    
    @State var themeColor: Color
    @State var emojisToAdd: String = ""
    
    init(theme: Binding<Theme<String>>) {
        _theme = theme
        themeColor = Color(rgba: theme.wrappedValue.color)
    }
    
    var body: some View {
        Form {
            Section {
                HStack {
                    TextField("Name", text: $theme.name)
                        .font(.title)
                        .foregroundStyle(Color(rgba: theme.color))
                    Spacer()
                    ColorPicker("Colors", selection: $themeColor)
                        .labelsHidden()
                        .onChange(of: themeColor) { _, newColor in
                            theme.color = RGBA(color: newColor)
                        }
                }
            }
            Section {
                VStack {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))]) {
                        ForEach(theme.contentSet, id: \.self) { emoji in
                            Text(emoji)
                                .font(.title)
                                .onTapGesture {
                                    withAnimation {
                                        theme.removeContent(emoji)
                                        emojisToAdd.remove(emoji.first!)
                                    }
                                }
                        }
                    }
                    TextField("Emojis", text: $emojisToAdd)
                        .font(.headline)
                        .textFieldStyle(.roundedBorder)
                        .padding(.top)
                        .onChange(of: emojisToAdd) { _, emojisToAdd in
                            theme.addContent(Array(emojisToAdd)) { emoji in
                                return emoji.first!.isEmoji
                            }
                        }
                    Stepper {
                        Text("\(theme.numberOfPairs) Pairs")
                    } onIncrement: {
                        theme.addPair()
                    } onDecrement: {
                        theme.removePair()
                    }
                }
            } header: {
                HStack {
                    Text("Emojis").font(.headline)
                    Spacer()
                    Text("Tap to include or exclude")
                }
            }
        }
    }
}

#Preview {
    @State var theme = ThemeStore(named: "Preview").themes.first!
    return ThemeEditor(theme: $theme)
}
//struct ThemeEditor_Previews: PreviewProvider {
//    struct Preview: View {
//        @State private var theme = ThemeStore(named: "Preview").themes.first!
//        
//        var body: some View {
//            ThemeEditor(theme: $theme)
//        }
//    }
//    
//    static var previews: some View {
//        Preview()
//    }
//}

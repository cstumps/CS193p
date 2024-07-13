//
//  EmojiArtDocumentView.swift
//  Emoji Art
//
//  Created by Jason Hirst on 6/26/24.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    typealias Emoji = EmojiArt.Emoji
    
    @ObservedObject var document: EmojiArtDocument
    
    private let emojis = "🍏🍎🍐🍊🍋🥑🍌🍉🍇🍓🫐🍒🍑🥝🥥🌮🍗🍔🥨🌶️🍿🍕🌽"
    private let paletteEmojiSize: CGFloat = 40
    
    var body: some View {
        VStack(spacing: 0) {
            documentBody
            PaletteChooser()
                .font(.system(size: paletteEmojiSize))
                .padding(.horizontal)
                .scrollIndicators(.hidden)
        }
    }
    
    private var documentBody: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white
                documentContents(in: geometry)
                    .scaleEffect(zoom * (selectedEmojis.isEmpty ? gestureZoom : 1))
                    .offset(pan + gesturePan)
            }
            .gesture(panGesture.simultaneously(with: zoomGesture))
            .dropDestination(for: Sturldata.self) { sturldatas, location in
                return drop(sturldatas, at: location, in: geometry)
            }
        }
    }
    
    @State private var zoom: CGFloat = 1
    @State private var pan: CGOffset = .zero
    
    @State private var selectedEmojis = Set<Int>()
    @State private var movingEmoji: Int? = nil
    
    @GestureState private var gestureZoom: CGFloat = 1
    @GestureState private var gesturePan: CGOffset =  .zero
    @GestureState private var gestureDragSelected: CGOffset = .zero
    
    private var gestureInFlight: Bool {
        return gesturePan != .zero || gestureZoom != 1 || gestureDragSelected != .zero
    }
    
    private var zoomGesture: some Gesture {
        MagnificationGesture()
            .updating($gestureZoom) { inMotionPinchScale, gestureZoom, _ in
                gestureZoom = inMotionPinchScale
            }
            
            .onEnded { endingPinchScale in
                if selectedEmojis.isEmpty {
                    zoom *= endingPinchScale
                } else {
                    for emojiId in selectedEmojis {
                        document.resize(emojiWithId: emojiId, by: endingPinchScale)
                    }
                }
            }
    }
    
    private var panGesture: some Gesture {
        DragGesture()
            .updating($gesturePan) { value, gesturePan, _ in
                gesturePan = value.translation
            }
            .onEnded { value in
                pan += value.translation
            }
    }
    
    private func dragSelectedGesture(_ emoji: Emoji) -> some Gesture {
        DragGesture()
            .updating($gestureDragSelected) { value, gestureDragSelected, _ in
                gestureDragSelected = value.translation
            }
            .onChanged { _ in
                movingEmoji = !selectedEmojis.contains(emoji.id) ? emoji.id : nil
            }
            .onEnded { value in
                if selectedEmojis.contains(emoji.id) {
                    for emojiId in selectedEmojis {
                        document.move(emojiWithId: emojiId, by: value.translation)
                    }
                } else {
                    document.move(emojiWithId: emoji.id, by: value.translation)
                }
            }
    }
    
    @ViewBuilder
    private func documentContents(in geometry: GeometryProxy) -> some View {
        AsyncImage(url: document.background) { phase in
            if let image = phase.image {
                image
            } else if let url = document.background {
                if phase.error != nil {
                    Text("\(url)")
                } else {
                    ProgressView()
                }
            }
        }
            .onTapGesture { selectedEmojis.removeAll() }
            .position(Emoji.Position.zero.in(geometry)) // Center background image in view
        ForEach(document.emojis) { emoji in
            Text(emoji.string)
                .font(emoji.font)
                .border((selectedEmojis.contains(emoji.id) && !gestureInFlight) ? DrawingConstants.selectionColor : .clear, width: DrawingConstants.selectionWidth)
                .scaleEffect(selectedEmojis.contains(emoji.id) ? gestureZoom : 1)
                .offset((selectedEmojis.contains(emoji.id) && movingEmoji == nil) || movingEmoji == emoji.id ? gestureDragSelected : .zero)
                .onTapGesture {
                    if selectedEmojis.contains(emoji.id) {
                        selectedEmojis.remove(emoji.id)
                    } else {
                        selectedEmojis.insert(emoji.id)
                    }
                }
                .onLongPressGesture {
                    document.deleteEmoji(emoji)
                    
                    if selectedEmojis.contains(emoji.id) {
                        selectedEmojis.remove(emoji.id)
                    }
                }
                .gesture(dragSelectedGesture(emoji))
                .position(emoji.position.in(geometry))

        }
    }
    
    private func drop(_ sturldatas: [Sturldata], at location: CGPoint, in geometry: GeometryProxy) -> Bool {
        // Note that this only drops the first item picked up since multiple items doesn't make
        // sense to drop on same location.  See returns breaking out of for loop.
        for sturldata in sturldatas {
            switch sturldata {
            case .url(let url):
                document.setBackground(url)
                return true
            case .string(let emoji):
                document.addEmoji(emoji, 
                                  at: emojiPosition(at: location, in: geometry),
                                  size: paletteEmojiSize / zoom
                )
                return true
            default:
                break
            }
        }
        
        return false
    }
    
    private func emojiPosition(at location: CGPoint, in geometry: GeometryProxy) -> Emoji.Position {
        let center = geometry.frame(in: .local).center
        
        return Emoji.Position(
            x: Int((location.x - center.x - pan.width) / zoom),
            y: Int(-(location.y - center.y - pan.height) / zoom)
        )
    }
    
    private struct DrawingConstants {
        static let selectionColor: Color = Color.yellow
        static let selectionWidth: CGFloat = 3
    }
}



#Preview {
    EmojiArtDocumentView(document: EmojiArtDocument())
        .environmentObject(PaletteStore(named: "Preview"))
}

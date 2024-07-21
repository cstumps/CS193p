//
//  EmojiArtDocumentView.swift
//  Emoji Art
//
//  Created by Jason Hirst on 6/26/24.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    @Environment(\.undoManager) var undoManager
    
    @StateObject var paletteStore = PaletteStore(named: "Shared")
    
    typealias Emoji = EmojiArt.Emoji
    
    @ObservedObject var document: EmojiArtDocument
    @ScaledMetric var paletteEmojiSize: CGFloat = 40
    
    var body: some View {
        VStack(spacing: 0) {
            documentBody
            PaletteChooser()
                .font(.system(size: paletteEmojiSize))
                .padding(.horizontal)
                .scrollIndicators(.hidden)
        }
        .toolbar {
            UndoButton()
        }
        .environmentObject(paletteStore)
    }
    
    private var documentBody: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white
                if document.background.isFetching {
                    ProgressView()
                        .scaleEffect(2)
                        .tint(.blue)
                        .position(Emoji.Position.zero.in(geometry))
                }
                documentContents(in: geometry)
                    .scaleEffect(zoom * (selectedEmojis.isEmpty ? gestureZoom : 1))
                    .offset(pan + gesturePan)
            }
            .gesture(panGesture.simultaneously(with: zoomGesture))
            .onTapGesture(count: 2) {
                zoomToFit(document.bbox, in: geometry)
            }
            .dropDestination(for: Sturldata.self) { sturldatas, location in
                return drop(sturldatas, at: location, in: geometry)
            }
            .onChange(of: document.background.failureReason) { _, reason in
                showBackgroundFailureAlert = (reason != nil)
            }
            .onChange(of: document.background.uiImage) { _, uiImage in
                zoomToFit(uiImage?.size, in: geometry)
            }
            .alert(
                "Set Background",
                isPresented: $showBackgroundFailureAlert,
                presenting: document.background.failureReason,
                actions: { reason in
                    Button("Ok", role: .cancel) { }
                },
                message: { reason in
                    Text(reason)
                }
            )
        }
    }
    
    private func zoomToFit(_ size: CGSize?, in geometry: GeometryProxy) {
        if let size {
            zoomToFit(CGRect(center: .zero, size: size), in: geometry)
        }
    }
    
    private func zoomToFit(_ rect: CGRect, in geometry: GeometryProxy) {
        withAnimation {
            if rect.size.width > 0, rect.size.height > 0,
               geometry.size.width > 0, geometry.size.height > 0 {
                let hZoom = geometry.size.width / rect.size.width
                let vZoom = geometry.size.height / rect.size.height
                
                zoom = min(hZoom, vZoom)
                pan = CGOffset(
                    width: -rect.midX * zoom,
                    height: -rect.midY * zoom
                )
            }
        }
    }
    
    @State private var showBackgroundFailureAlert = false
    
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
                        document.resize(emojiWithId: emojiId, by: endingPinchScale, undoWoth: undoManager)
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
                        document.move(emojiWithId: emojiId, by: value.translation, undoWoth: undoManager)
                    }
                } else {
                    document.move(emojiWithId: emoji.id, by: value.translation, undoWoth: undoManager)
                }
            }
    }
    
    @ViewBuilder
    private func documentContents(in geometry: GeometryProxy) -> some View {
        if let uiImage = document.background.uiImage {
            Image(uiImage: uiImage)
                .onTapGesture { selectedEmojis.removeAll() }
                .position(Emoji.Position.zero.in(geometry)) // Center background image in view
        }
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
                    document.deleteEmoji(emoji, undoWith: undoManager)
                    
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
                document.setBackground(url, undoWith: undoManager)
                return true
            case .string(let emoji):
                document.addEmoji(emoji, 
                                  at: emojiPosition(at: location, in: geometry),
                                  size: paletteEmojiSize / zoom,
                                  undoWith: undoManager
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

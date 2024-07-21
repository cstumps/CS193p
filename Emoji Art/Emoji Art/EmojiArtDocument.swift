//
//  EmojiArtDocument.swift
//  Emoji Art
//
//  Created by Jason Hirst on 6/26/24.
//

import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static let emojiart = UTType(exportedAs: "me.fornost.emojiart")
}

class EmojiArtDocument: ReferenceFileDocument {
    func snapshot(contentType: UTType) throws -> Data {
        try emojiArt.json()
    }
    
    func fileWrapper(snapshot: Data, configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: snapshot)
    }

    static var readableContentTypes: [UTType] {
        [.emojiart]
    }
    
    required init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            emojiArt = try EmojiArt(json: data)
        } else {
            throw CocoaError(.fileReadCorruptFile)
        }
    }
    
    typealias Emoji = EmojiArt.Emoji
    
    @Published private var emojiArt = EmojiArt() {
        didSet {
            // Process the state machine if the background image has changed during this model update
            if emojiArt.background != oldValue.background {
                Task {
                    await fetchBackgroundImage()
                }
            }
        }
    }
    
    init() {

    }
    
    var emojis: [Emoji] {
        emojiArt.emojis
    }
    
    var bbox: CGRect {
        var bbox = CGRect.zero
        
        for emoji in emojiArt.emojis {
            bbox = bbox.union(emoji.bbox)
        }
        
        if let backgroundSize = background.uiImage?.size {
            bbox = bbox.union(CGRect(center: .zero, size: backgroundSize))
        }
        
        return bbox
    }
    
//    var background: URL? {
//        emojiArt.background
//    }
    
    // This is neat.  By exposing the view to the state the background is in, it will
    // know if it's fetching, found, has an error, etc.
    
    @Published var background: Background = .none
    
    // MARK: - Background image
    
    // Without the main actor tag, when background = .found and the image loads, because it's
    // published it redraws the main view.  Doing this from anything other than the main actor
    // is not allowed and we get runtime errors.
    
    @MainActor
    private func fetchBackgroundImage() async {
        if let url = emojiArt.background {
            background = .fetching(url)
            do {
                let image = try await fetchUIImage(from: url)
                
                // This check ensures we don't wipe out a background if the user drags a new one on
                // while a previos one is still loading.
                if url == emojiArt.background {
                    background = .found(image)
                }
            } catch { //let error {
                background =  .failed("Couldn't set background: \(error.localizedDescription)")
            }
            
        } else { // If emojiArt.background == nil
            background = .none
        }
    }
    
    private func fetchUIImage(from url: URL) async throws -> UIImage {
        let (data, _) = try await URLSession.shared.data(from: url)
        if let uiImage = UIImage(data: data) {
            return uiImage
        } else {
            throw FetchError.badImageData
        }
    }
    
    enum FetchError: Error {
        case badImageData
    }
    
    enum Background {
        case none
        case fetching(URL)
        case found(UIImage)
        case failed(String)
        
        var uiImage: UIImage? {
            switch self {
            case .found(let uiImage): return uiImage
            default: return nil
            }
        }
        
        var urlBeingFetched: URL? {
            switch self {
            case .fetching(let url): return url
            default: return nil
            }
        }
        
        var isFetching: Bool { urlBeingFetched != nil }
        
        var failureReason: String? {
            switch self {
            case .failed(let reason): return reason
            default: return nil
            }
        }
    }
    
    // MARK: - Undo
    
    private func undoablyPerform(_ action: String, with undoManager: UndoManager? = nil, doit: () -> Void) {
        let oldEmojiArt = emojiArt
        
        doit()
        
        undoManager?.registerUndo(withTarget: self) { myself in
            myself.undoablyPerform(action, with: undoManager) {
                myself.emojiArt = oldEmojiArt
            }
        }
        
        undoManager?.setActionName(action)
    }
    
    // MARK: - Intent(s)
    
    func setBackground(_ url: URL?, undoWith undoManager: UndoManager? = nil) {
        undoablyPerform("Set Background", with: undoManager) {
            emojiArt.background = url
        }
    }
    
    // Decided to allow size here to be a CGFloat to make it easier on the view since thats
    // what it will likely pass
    func addEmoji(_ emoji: String, at position: Emoji.Position, size: CGFloat, undoWith undoManager: UndoManager? = nil) {
        undoablyPerform("Add \(emoji)", with: undoManager) {
            emojiArt.addEmoji(emoji, at: position, size: Int(size))
        }
    }
    
    func deleteEmoji(_ emoji: Emoji, undoWith undoManager: UndoManager? = nil) {
        undoablyPerform("Delete \(emoji)", with: undoManager) {
            emojiArt.deleteEmoji(emoji)
        }
    }
    
    // These were added by the professor to make the homework easier
    func move(_ emoji: Emoji, by offset: CGOffset, undoWith undoManager: UndoManager? = nil) {
        undoablyPerform("Move \(emoji)", with: undoManager) {
            let existingPosition = emojiArt[emoji].position
            
            emojiArt[emoji].position = Emoji.Position(
                x: existingPosition.x + Int(offset.width),
                y: existingPosition.y - Int(offset.height)
            )
        }
    }

    func move(emojiWithId id: Emoji.ID, by offset: CGOffset, undoWoth undoManager: UndoManager? = nil) {
        if let emoji = emojiArt[id] {
            move(emoji, by: offset, undoWith: undoManager)
        }
    }

    func resize(_ emoji: Emoji, by scale: CGFloat, undoWith undoManager: UndoManager? = nil) {
        undoablyPerform("Resize \(emoji)", with: undoManager) {
            emojiArt[emoji].size = Int(CGFloat(emojiArt[emoji].size) * scale)
        }
    }

    func resize(emojiWithId id: Emoji.ID, by scale: CGFloat, undoWoth undoManager: UndoManager? = nil) {
        if let emoji = emojiArt[id] {
            resize(emoji, by: scale, undoWith: undoManager)
        }
    }
}

extension EmojiArt.Emoji {
    var font: Font {
        Font.system(size: CGFloat(size))
    }
    
    var bbox: CGRect {
        CGRect(
            center: position.in(nil),
            size: CGSize(width: CGFloat(size), height: CGFloat(size))
        )
    }
}

extension EmojiArt.Emoji.Position {
    func `in`(_ geometry: GeometryProxy?) -> CGPoint {
        let center = geometry?.frame(in: .local).center ?? .zero
        return CGPoint(x: center.x + CGFloat(x), y: center.y - CGFloat(y))
    }
}

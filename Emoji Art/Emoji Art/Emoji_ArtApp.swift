//
//  Emoji_ArtApp.swift
//  Emoji Art
//
//  Created by Jason Hirst on 6/26/24.
//

import SwiftUI

@main
struct Emoji_ArtApp: App {    
    var body: some Scene {
        //WindowGroup {
        DocumentGroup(newDocument: { EmojiArtDocument() }) { config in
            EmojiArtDocumentView(document: config.document)
        }
    }
}

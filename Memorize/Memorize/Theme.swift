//
//  Theme.swift
//  Memorize
//
//  Created by Jason Hirst on 4/29/23.
//

import Foundation

struct Theme<CardContent>: Identifiable, Codable, Hashable where CardContent: Hashable,
                                                                 CardContent: Codable {
    var name: String
    var color: RGBA
    var id = UUID()
    
    private(set) var contentSet: Array<CardContent>
    private(set) var removedContent: Array<CardContent>
    private(set) var numberOfPairs: Int
    
    init(name: String, color: RGBA, numberOfPairs: Int, contentSet: [CardContent]) {
        self.name = name
        self.color = color
        self.numberOfPairs = min(numberOfPairs, contentSet.count)
        self.contentSet = contentSet
        self.removedContent = []
    }
    
    init(name: String, color: RGBA, contentSet: [CardContent], randomNumberOfPairs: Bool = false) {
        self.name = name
        self.color = color
        self.numberOfPairs = randomNumberOfPairs ? Int.random(in: 2..<contentSet.count) : contentSet.count
        self.contentSet = contentSet
        self.removedContent = []
    }
    
    func returnCardSet() -> [CardContent] {
        Array<CardContent>(contentSet.shuffled()[0..<numberOfPairs])
    }
    
    mutating func addPair() {
        numberOfPairs = min(contentSet.count, numberOfPairs + 1)
    }
    
    mutating func removePair() {
        numberOfPairs = max(2, numberOfPairs - 1)
    }
    
    mutating func removeContent(_ contentToRemove: CardContent) {
        if numberOfPairs > 2,
           let index = contentSet.firstIndex(where: { $0 == contentToRemove }) {
            contentSet.remove(at: index)
            numberOfPairs = min(contentSet.count, numberOfPairs)
            
            // Add content to the removed set
            removedContent.append(contentToRemove)
        }
    }
    
    mutating func addContent(_ contentToAdd: CardContent) {
        contentSet.append(contentToAdd)
        
        // If this content is in the removed set, remove it when we make it active again
        if let index = removedContent.firstIndex(where: { $0 == contentToAdd }) {
            removedContent.remove(at: index)
        }
    }
}

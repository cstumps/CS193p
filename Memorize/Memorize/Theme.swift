//
//  Theme.swift
//  Memorize
//
//  Created by Jason Hirst on 4/29/23.
//

import Foundation

struct Theme<CardContent> {
    private(set) var name: String
    private(set) var color: String
    private(set) var numberOfPairs: Int
    
    private var contentSet: Array<CardContent>
    
    init(name: String, color: String, numberOfPairs: Int, contentSet: [CardContent]) {
        self.name = name
        self.color = color
        self.numberOfPairs = min(numberOfPairs, contentSet.count)
        self.contentSet = contentSet
    }
    
    init(name: String, color: String, contentSet: [CardContent], randomNumberOfPairs: Bool = false) {
        self.name = name
        self.color = color
        self.numberOfPairs = randomNumberOfPairs ? Int.random(in: 2..<contentSet.count) : contentSet.count
        self.contentSet = contentSet
    }
    
    func returnCardSet() -> [CardContent] {
        Array<CardContent>(contentSet.shuffled()[0..<numberOfPairs])
    }
}

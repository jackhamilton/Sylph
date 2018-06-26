//
//  Song.swift
//  Sylph
//
//  Created by Jack Hamilton on 6/18/18.
//  Copyright © 2018 Dropkick. All rights reserved.
//

import Foundation

class Difficulty {
    public var hits: [Note] = []
    public var difficulty: Int
    public var difficultyName: String
    
    private var noteIterator: Int
    
    public init(hits: [Note], difficultyName: String, difficulty: Int) {
        self.hits = hits
        self.difficultyName = difficultyName
        self.difficulty = difficulty
        noteIterator = 0
    }
    
    public func advanceNextNote() -> Note? {
        if (noteIterator < hits.count) {
            noteIterator += 1
            return hits[noteIterator - 1]
        } else {
            return nil
        }
    }
    
    public func peekNextNote() -> Note? {
        if (noteIterator < hits.count) {
            return hits[noteIterator]
        } else {
            return nil
        }
    }
    
}

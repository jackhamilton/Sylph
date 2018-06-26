//
//  Hit.swift
//  Sylph
//
//  Created by Jack Hamilton on 6/18/18.
//  Copyright © 2018 Dropkick. All rights reserved.
//

import Foundation
import SpriteKit

class Note {
    public var time: Double!
    public var hitCircleIndex: Int!
    public var hitCirclePosition: CGPoint = CGPoint(x: 0, y: 0)
    public var sprite: NoteSprite?
    
    public init (time: Double, hitCircleIndex: Int) {
        self.time = time
        self.hitCircleIndex = hitCircleIndex
    }
}

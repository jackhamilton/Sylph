//
//  NoteSprite.swift
//  Sylph
//
//  Created by Jack Hamilton on 6/20/18.
//  Copyright © 2018 Dropkick. All rights reserved.
//

import Foundation
import SpriteKit

class NoteSprite: SKSpriteNode {
    
    public static let texture = SKTexture(imageNamed: "hitcircleoverlay")
    
    public init (note: Note) {
        super.init(texture: NoteSprite.texture, color: UIColor.clear, size: NoteSprite.texture.size())
        self.isHidden = true
        self.setScale(1.2)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

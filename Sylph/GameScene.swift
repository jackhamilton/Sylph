//
//  GameScene.swift
//  Sylph
//
//  Created by Jack Hamilton on 6/13/18.
//  Copyright © 2018 Dropkick. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

class GameScene: SKScene {
    
    public static var difficultyToPlay: Int = 0
    public static var currentSong: Song?
    var foreground: SKNode!
    var noteLayer: SKNode!
    var hit0: SKSpriteNode!
    var hit1: SKSpriteNode!
    var hit2: SKSpriteNode!
    var hit3: SKSpriteNode!
    var hit0highlight: SKSpriteNode!
    var hit1highlight: SKSpriteNode!
    var hit2highlight: SKSpriteNode!
    var hit3highlight: SKSpriteNode!
    var hitButtons: [SKSpriteNode]!
    var hitHighlights: [SKSpriteNode]!
    var hitReacts: [SKSpriteNode?]!
    var timeLabel: SKLabelNode!
    var activatedHitTouches: [[UITouch]]!
    var timeOfLastUpdate: TimeInterval!
    var notes: [Note] = []
    var onscreenNotes: [Note] = []
    let approachRate: Double = 3 //seconds from top to bottom
    //The second range for each grade
    let badSeconds: Double = 0.5
    let okSeconds: Double = 0.30
    let goodSeconds: Double = 0.15
    let perfectSeconds: Double = 0.08
    let screenSize = UIScreen.main.bounds
    var score = 0
    var combo = 0
    var scoreLabel: SKLabelNode!
    var comboLabel: SKLabelNode!
    
    override func didMove(to view: SKView) {
        scene?.scaleMode = SKSceneScaleMode.aspectFit
        foreground = childNode(withName: "Foreground")!
        noteLayer = childNode(withName: "Notes")!
        timeLabel = foreground.childNode(withName: "Time") as! SKLabelNode
        scoreLabel = foreground.childNode(withName: "Score") as! SKLabelNode
        comboLabel = foreground.childNode(withName: "Combo") as! SKLabelNode
        hit0 = foreground.childNode(withName: "hit1") as! SKSpriteNode
        hit1 = foreground.childNode(withName: "hit2") as! SKSpriteNode
        hit2 = foreground.childNode(withName: "hit3") as! SKSpriteNode
        hit3 = foreground.childNode(withName: "hit4") as! SKSpriteNode
        hitButtons = [hit0, hit1, hit2, hit3]
        hit0highlight = foreground.childNode(withName: "hit1highlight") as! SKSpriteNode
        hit1highlight = foreground.childNode(withName: "hit2highlight") as! SKSpriteNode
        hit2highlight = foreground.childNode(withName: "hit3highlight") as! SKSpriteNode
        hit3highlight = foreground.childNode(withName: "hit4highlight") as! SKSpriteNode
        hit0highlight.alpha = 0
        hit1highlight.alpha = 0
        hit2highlight.alpha = 0
        hit3highlight.alpha = 0
        hitHighlights = [hit0highlight, hit1highlight, hit2highlight, hit3highlight]
        let hit0Touches: [UITouch] = []
        let hit1Touches: [UITouch] = []
        let hit2Touches: [UITouch] = []
        let hit3Touches: [UITouch] = []
        activatedHitTouches = [hit0Touches, hit1Touches, hit2Touches, hit3Touches]
        hitReacts = [nil, nil, nil, nil]
        timeOfLastUpdate = 0;
        /*
        currentSong = Song(hits: [Note(time: 3, hitCircleIndex: 3),
                                  Note(time: 4, hitCircleIndex: 2),
                                  Note(time: 5, hitCircleIndex: 0),
                                  Note(time: 5, hitCircleIndex: 3),
                                  Note(time: 5.5, hitCircleIndex: 1),
                                  Note(time: 6, hitCircleIndex: 2)
                                    ], length: 180.00)*/
        let music = SKAudioNode(url: GameScene.currentSong!.mp3URL)
        music.autoplayLooped = false
        addChild(music)
        music.run(SKAction.play())
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchPosition = touch.location(in: self)
            //Add any touches to respective button arrays
            for i in 0...3 {
                let buttonFrame: CGRect = hitButtons[i].frame
                //Create a new bounding box covering the screen height-wise
                let hitBounds = CGRect(x: buttonFrame.minX, y: -2000,
                                       width: buttonFrame.maxX - buttonFrame.minX,
                                       height: 4000)
                if (hitBounds.contains(touchPosition)) {
                    activatedHitTouches[i].append(touch)
                    hitButtons[i].run(SKAction.scale(to: 1.2, duration: 0.03))
                    //Check if any notes got hit.
                    if (onscreenNotes.count > 0) {
                        var cont: Bool = true
                        for j in 0...(onscreenNotes.count - 1) {
                            if (cont) {
                                let note = onscreenNotes[j]
                                //if it's in the same hitcircle you just hit
                                if (note.hitCircleIndex == i
                                    //And there's a song playing
                                    && GameScene.currentSong != nil
                                    //And the hit was within a bad hit time of the note's time
                                    && abs(GameScene.currentSong!.currentTime - note.time) < badSeconds) {
                                    //You hit this note, let's decide which grade to give it.
                                    let disparity = abs(GameScene.currentSong!.currentTime - note.time)
                                    var img: SKSpriteNode?
                                    if (disparity < perfectSeconds) {
                                        img = SKSpriteNode(imageNamed: "TUBULAR")
                                        score += 8 * combo
                                        combo += 1
                                    } else if (disparity < goodSeconds) {
                                        img = SKSpriteNode(imageNamed: "INTENSE")
                                        score += 6 * combo
                                        combo += 1
                                    } else if (disparity < okSeconds) {
                                        img = SKSpriteNode(imageNamed: "OKAY")
                                        score += 2 * combo
                                        combo += 1
                                    } else {
                                        img = SKSpriteNode(imageNamed: "GARBAGE")
                                        combo = 0
                                    }
                                    if (hitReacts[i] != nil) {
                                        hitReacts[i]?.removeAllActions()
                                        hitReacts[i]?.removeFromParent()
                                    }
                                    img!.setScale(0.8)
                                    img!.position = hitButtons[i].position
                                    img!.position.y += 150
                                    img!.run(SKAction.sequence([
                                        SKAction.wait(forDuration: 0.3),
                                        SKAction.fadeOut(withDuration: 0.3),
                                        SKAction.removeFromParent()
                                        ]))
                                    img!.zPosition = 1
                                    hitReacts[i] = img
                                    noteLayer.addChild(img!)
                                    //But for now, we're actually just gonna vanish the note.
                                    note.sprite!.run(SKAction.sequence(
                                        [SKAction.group([SKAction.scale(by: 2.0, duration: 0.2),
                                                                SKAction.fadeOut(withDuration: 0.2)]),
                                                              SKAction.removeFromParent()]))
                                    onscreenNotes.remove(at: j)
                                    //Let's also play the highlight.
                                    hitHighlights[i].removeAllActions()
                                    hitHighlights[i].alpha = 1
                                    hitHighlights[i].run(SKAction.fadeOut(withDuration: 0.2))
                                    //we only want to remove the first one, and we don't want to
                                    //remove something while we're iterating, so let's kill the loop.
                                    cont = false
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            //check all of the arrays for the touch, remove it if so
            //make a modifiable copy of activatedHitTouches
            var touchesCopy: [[UITouch]] = activatedHitTouches
            for i in 0...3 {
                //Go through however many touches are in the selected hit's array, but don't do
                //anything if there aren't any.
                if (activatedHitTouches[i].count > 0) {
                    for j in 0...(activatedHitTouches[i].count - 1) {
                        if (activatedHitTouches[i][j].isEqual(touch)) {
                            //Can't remove it while iterating through it, so we'll modify the copy we made
                            touchesCopy[i].remove(at: j)
                        }
                    }
                }
            }
            activatedHitTouches = touchesCopy
        }
        for j in 0...3 {
            if (activatedHitTouches[j].isEmpty) {
                hitButtons[j].run(SKAction.scale(to: 1.4, duration: 0.03))
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        //if the delta since last update is less than half a second, the game probably wasn't paused.
        if (currentTime - timeOfLastUpdate < 0.5) {
            var timeSinceLastUpdate: TimeInterval! //This doesn't need to be done on two lines, but since it's a weird type, I thought it might be a good idea.
            timeSinceLastUpdate = currentTime - timeOfLastUpdate
            if (GameScene.currentSong != nil && GameScene.currentSong!.currentTime < GameScene.currentSong!.length) {
                GameScene.currentSong!.currentTime += timeSinceLastUpdate;
                //Update the timer label
                timeLabel.text = String(Int((GameScene.currentSong!.currentTime.truncatingRemainder(dividingBy: 3600)) / 60))
                timeLabel.text! += ":"
                //we always want it in the format 0:00, so add a zero if seconds < 10
                //this dumb method is just %, so this is time % 60, or seconds elapsed
                if (GameScene.currentSong!.currentTime.truncatingRemainder(dividingBy: 60) < 10) {
                    timeLabel.text! += "0"
                }
                timeLabel.text! += String(Int(GameScene.currentSong!.currentTime.truncatingRemainder(dividingBy: 60)))
                
                //update current note positions
                for note in onscreenNotes {
                    let secondsUntilHit = note.time - GameScene.currentSong!.currentTime
                    let percentageToHit = CGFloat(secondsUntilHit/approachRate)
                    note.sprite!.position = CGPoint(x: note.hitCirclePosition.x, y: note.hitCirclePosition.y + screenSize.height * 2 * percentageToHit)
                }
                
                //Delete any offscreen notes
                while (onscreenNotes.first != nil &&
                    onscreenNotes.first!.sprite!.position.y < onscreenNotes.first!.hitCirclePosition.y - onscreenNotes.first!.sprite!.frame.size.height * 1.1) {
                    onscreenNotes.first?.sprite!.removeFromParent()
                    combo = 0
                        //Copy of above code
                    let img = SKSpriteNode(imageNamed: "GARBAGE")
                    let i = onscreenNotes.first?.hitCircleIndex
                    img.setScale(0.8)
                    img.position = hitButtons[i!].position
                    img.position.y += 150
                    img.run(SKAction.sequence([
                        SKAction.wait(forDuration: 0.3),
                        SKAction.fadeOut(withDuration: 0.3),
                        SKAction.removeFromParent()
                        ]))
                    img.zPosition = 1
                    hitReacts[i!] = img
                    noteLayer.addChild(img)
                    onscreenNotes.removeFirst()
                }
                
                //Render any new notes
                //if the time of the next note is less than the current time minus the AR, render the note.
                while (GameScene.currentSong!.difficulties[GameScene.difficultyToPlay].peekNextNote() != nil &&
                    GameScene.currentSong!.difficulties[GameScene.difficultyToPlay].peekNextNote()!.time - approachRate < GameScene.currentSong!.currentTime) {
                        //move the song on to the next note. Non-optional
                        let tmpNoteBase: Note = GameScene.currentSong!.difficulties[GameScene.difficultyToPlay].advanceNextNote()!
                        let tmpNote: NoteSprite = NoteSprite(note: tmpNoteBase)
                        tmpNoteBase.sprite = tmpNote
                        tmpNote.isHidden = false
                        //position it a screen height above the right hitcircle
                        let hitCircle = hitButtons[tmpNoteBase.hitCircleIndex]
                        tmpNoteBase.hitCirclePosition = CGPoint(x: hitCircle.position.x * 0.96, y: hitCircle.position.y)
                        let secondsUntilHit = tmpNoteBase.time - GameScene.currentSong!.currentTime
                        let percentageToHit = CGFloat(secondsUntilHit/approachRate)
                        tmpNote.position = CGPoint(x: tmpNoteBase.hitCirclePosition.x, y: tmpNoteBase.hitCirclePosition.y + screenSize.height * 2 * percentageToHit)
                        noteLayer.addChild(tmpNote)
                        onscreenNotes.append(tmpNoteBase)
                }
            }
        }
        timeOfLastUpdate = currentTime
        scoreLabel.text = String(score)
        comboLabel.text = "x" + String(combo)
    }
}

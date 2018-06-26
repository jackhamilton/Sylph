//
//  BlackBoxConverter.swift
//  Sylph
//
//  Created by Jack Hamilton on 6/19/18.
//  Copyright © 2018 Dropkick. All rights reserved.
//

import Foundation

class BlackBoxConverter {
    
    private var offset: Double = 0.0
    private var bpms: [BPMPair] = []
    //contains an array of songs, which are arrays of blocks (an array of strings representing bars)
    private var difficulties:[[[String]]] = []
    private var difficultyValues: [Int] = []
    private var difficultyNames: [String] = []
    private var formattedDifficulties:[Difficulty] = []
    private var mp3URL: URL = URL(fileURLWithPath: "")
    private var bgURL: URL = URL(fileURLWithPath: "")
    private var length: Double = 0
    private var title: String = ""
    private var artist: String = ""
    
    public func convertStepfile (dirPath: String, filePath: String, songTimePad: Double) -> Song {
        formattedDifficulties = []
        difficulties = []
        bpms = []
        offset = 0.0
        do {
            let text = try String(contentsOfFile: filePath)
            //Separate by line
            var lines: [String] = text.components(separatedBy: "\n")
            var line = lines[0]
            //Get title
            while (!line.contains("#TITLE:")) {
                lines.removeFirst()
                line = lines[0]
            }
            var start = line.index(line.startIndex, offsetBy: "#TITLE:".count)
            var end = line.index(line.endIndex, offsetBy: -2)
            title = String(line[start..<end])
            //get artist
            while (!line.contains("#ARTIST:")) {
                lines.removeFirst()
                line = lines[0]
            }
            start = line.index(line.startIndex, offsetBy: "#ARTIST:".count)
            end = line.index(line.endIndex, offsetBy: -2)
            artist = String(line[start..<end])
            //get background URL
            while (!line.contains("#BACKGROUND:")) {
                lines.removeFirst()
                line = lines[0]
            }
            start = line.index(line.startIndex, offsetBy: "#BACKGROUND:".count)
            end = line.index(line.endIndex, offsetBy: -2)
            bgURL = URL(fileURLWithPath: dirPath + String(line[start..<end]))
            //Get the filename
            while (!line.contains("#MUSIC:")) {
                lines.removeFirst()
                line = lines[0]
            }
            start = line.index(line.startIndex, offsetBy: "#MUSIC:".count)
            end = line.index(line.endIndex, offsetBy: -2)
            mp3URL = URL(fileURLWithPath: dirPath + String(line[start..<end]))
            //Get the offset
            while (!line.contains("#OFFSET:")) {
                lines.removeFirst()
                line = lines[0]
            }
            start = line.index(line.startIndex, offsetBy: "#OFFSET:".count)
            end = line.index(line.endIndex, offsetBy: -2)
            offset = Double(String(line[start..<end]))!
            //Get the bpms as the internal BPMPair struct type
            while (!line.contains("#BPMS:")) {
                lines.removeFirst()
                line = lines[0]
            }
            start = line.index(line.startIndex, offsetBy: "#BPMS:".count)
            end = line.index(line.endIndex, offsetBy: -2)
            let bpmsfull = String(line[start..<end])
            //Split into pairs (x=y)
            let bpmsplit: [String] = bpmsfull.components(separatedBy: ",")
            for s in bpmsplit {
                //Split into numbers and build the struct
                let bpmpair = s.components(separatedBy: "=")
                let tmpbpm:BPMPair = BPMPair(start: Double(bpmpair[0])!, bpm: Double(bpmpair[1])!)
                bpms.append(tmpbpm)
            }
            //Construct the blocks
            var blocks:[[String]] = []
            var noteseq: [String] = []
            
            //Start at the notes section
            var i = 0
            while (!(i+1 >= lines.count) &&
                !lines[i+1].starts(with: "0") &&
                !lines[i+1].starts(with: "1") &&
                !lines[i+1].starts(with: "2") &&
                !lines[i+1].starts(with: "3") &&
                !lines[i+1].starts(with: "4") &&
                !lines[i+1].starts(with: "M") &&
                !lines[i+1].starts(with: "L") &&
                !lines[i+1].starts(with: "F") &&
                !lines[i+1].starts(with: "S") &&
                !lines[i].starts(with: "#NOTES")) {
                    i += 1
            }
            //while loop because iterators are passed by value into the code
            while (i < lines.count) {
                var l = lines[i]
                //New difficulty detected
                if ((!l.contains("0") && !l.contains("1") && !l.contains(",") && !l.contains(";")) ||
                    l.starts(with: "#")) {
                    if (blocks.count > 0) {
                        difficulties.append(blocks)
                        blocks = []
                    }
                    //Skip to the next difficulty's notes section
                    while (!(i+1 >= lines.count) &&
                        !lines[i+1].starts(with: "0") &&
                        !lines[i+1].starts(with: "1") &&
                        !lines[i+1].starts(with: "2") &&
                        !lines[i+1].starts(with: "3") &&
                        !lines[i+1].starts(with: "4") &&
                        !lines[i+1].starts(with: "M") &&
                        !lines[i+1].starts(with: "L") &&
                        !lines[i+1].starts(with: "F") &&
                        !lines[i+1].starts(with: "S") &&
                        !lines[i].starts(with: "#NOTES") &&
                        !lines[i-1].contains("dance-single")) {
                        i += 1
                    }
                    //Parse the notes section for difficulty names and values
                    if (lines[i].starts(with: "#NOTES")) {
                        i += 3
                        difficultyNames.append(
                            String(lines[i][lines[i].startIndex..<lines[i].index(lines[i].endIndex, offsetBy: -2)]))
                        i += 1
                        difficultyValues.append(
                            Int(String(
                                lines[i][lines[i].startIndex..<lines[i].index(lines[i].endIndex, offsetBy: -2)]).trimmingCharacters(in: .whitespaces))!)
                    }
                    //Skip to difficulty's beatmapping
                    while (!(i+1 >= lines.count) &&
                        !lines[i].starts(with: "0") &&
                        !lines[i].starts(with: "1") &&
                        !lines[i].starts(with: "2") &&
                        !lines[i].starts(with: "3") &&
                        !lines[i].starts(with: "4") &&
                        !lines[i].starts(with: "M") &&
                        !lines[i].starts(with: "L") &&
                        !lines[i].starts(with: "F") &&
                        !lines[i].starts(with: "S")) {
                            i += 1
                    }
                }
                l = lines[i]
                //Otherwise, keep parsing the current difficulty
                if (l.starts(with: ",") || l.starts(with: ";")) {
                    blocks.append(noteseq)
                    noteseq = []
                } else if (!l.elementsEqual("\r")) {
                    noteseq.append(l)
                }
                i += 1
            }
        } catch {
            print("Unknown error: could not convert stepfile.")
        }
        
        
        for i in 0..<difficulties.count {
            //Run through the time conversion process
            var beat = 0.0
            var cTime = offset * -1
            var bpmIndex = 0
            var cSongPreproccesed: [Bar] = []
            //Calculate beat variable on bars, organize difficulties
            for measure in 0..<difficulties[i].count {
                let beatIncrement = 4.0/Double(difficulties[i][measure].count)
                for cbar in difficulties[i][measure] {
                    var cBar = cbar
                    cBar = cBar.replacingOccurrences(of: "M", with: "0")
                    cBar = cBar.replacingOccurrences(of: "L", with: "0")
                    cBar = cBar.replacingOccurrences(of: "F", with: "0")
                    cBar = cBar.replacingOccurrences(of: "S", with: "0")
                    let tmpBar: Bar = Bar(hit1: Int(String(cBar[cBar.index(cBar.startIndex, offsetBy: 0)]))!,
                                          hit2: Int(String(cBar[cBar.index(cBar.startIndex, offsetBy: 1)]))!,
                                          hit3: Int(String(cBar[cBar.index(cBar.startIndex, offsetBy: 2)]))!,
                                          hit4: Int(String(cBar[cBar.index(cBar.startIndex, offsetBy: 3)]))!,
                                          beat: beat)
                    beat += beatIncrement
                    cSongPreproccesed.append(tmpBar)
                }
            }
            beat = 0
            bpmIndex = 0
            var cSongNotes: [Note] = []
            //The beat value of this pair won't be updated, so just use it for bpm.
            var cBPM = bpms[bpmIndex]
            for cBar in cSongPreproccesed {
                //Events: bpm change, note
                //Either we want to get to the next BPM change and add the time ((new beat - old beat) * 60/cBpm) or we want to go to the next note and add the time. Whichever's smaller.
                
                //Catch up with beat changes
                while (bpmIndex + 1 < bpms.count &&
                    bpms[bpmIndex + 1].start <= cBar.beat) {
                    cTime += (60.0/(cBPM.bpm)) * (bpms[bpmIndex + 1].start - beat)
                    beat = bpms[bpmIndex + 1].start
                    cBPM = bpms[bpmIndex + 1]
                    bpmIndex += 1
                }
                //Process current bar
                cTime += (60.0/(cBPM.bpm)) * (cBar.beat - beat)
                beat = cBar.beat
                //Add it to the song
                //This is where you'd do testing to add any freeze notes or whatnot
                if (cBar.hit1 != 0) {
                    let tmpNote = Note(time: cTime, hitCircleIndex: 0)
                    cSongNotes.append(tmpNote)
                }
                if (cBar.hit2 != 0) {
                    let tmpNote = Note(time: cTime, hitCircleIndex: 1)
                    cSongNotes.append(tmpNote)
                }
                if (cBar.hit3 != 0) {
                    let tmpNote = Note(time: cTime, hitCircleIndex: 2)
                    cSongNotes.append(tmpNote)
                }
                if (cBar.hit4 != 0) {
                    let tmpNote = Note(time: cTime, hitCircleIndex: 3)
                    cSongNotes.append(tmpNote)
                }
            }
            length = cTime + songTimePad
            formattedDifficulties.append(Difficulty(hits: cSongNotes, difficultyName: difficultyNames[i], difficulty: difficultyValues[i]))
        }
        let song: Song = Song(difficulties: formattedDifficulties, name: title, artist: artist, length: length, currentTime: 0, mp3URL: mp3URL, bgURL: bgURL)
        return song
    }
}

struct BPMPair {
    var start: Double
    var bpm: Double
}

struct Bar {
    let hit1: Int
    let hit2: Int
    let hit3: Int
    let hit4: Int
    var beat: Double
}

//
//  SongSelectController.swift
//  Sylph
//
//  Created by Jack Hamilton on 6/21/18.
//  Copyright © 2018 Dropkick. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class SongSelectController : UIViewController {
    
    @IBOutlet weak var songImageDetail: UIImageView!
    @IBOutlet weak var difficultySelect: UIStackView!
    @IBOutlet weak var songTitleDetail: UILabel!
    @IBOutlet weak var songDescriptionDetail: UILabel!
    @IBOutlet weak var Table: UITableView!
    @IBOutlet weak var songDetail: UIView!
    public var currentSongs: [Song] = []
    private var selectedSong: Int = 0
    
    var strokeTextAttributes: [NSAttributedStringKey: Any] = [:]
    
    override func viewDidLoad() {
        Table.rowHeight = 100
        songTitleDetail.isHidden = true
        songDescriptionDetail.isHidden = true
        //setup stroke text
        strokeTextAttributes = [
            .strokeColor : UIColor.black,
            .strokeWidth : -2.0
        ]
        
        //Read the Songs directory
        let b = BlackBoxConverter()
        let fm = FileManager.default
        var path = Bundle.main.resourcePath!
        path += "/Songs/"
        do {
            let songs = try fm.contentsOfDirectory(atPath: path)
            
            for song in songs {
                print("Found \(song)")
                let songPath = path + song + "/"
                let files = try? fm.contentsOfDirectory(atPath: songPath)
                if (files != nil) {
                    for file in files! {
                        if (file.contains(".sm")) {
                            currentSongs.append(b.convertStepfile(dirPath: songPath, filePath: songPath + file, songTimePad: 3.0))
                        }
                    }
                }
            }
        } catch {
            // failed to read directory
        }
    }
    
}

extension SongSelectController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentSongs.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        songTitleDetail.attributedText = NSMutableAttributedString(string: currentSongs[indexPath.row].name, attributes: strokeTextAttributes)
        songTitleDetail.isHidden = false
        songDescriptionDetail.attributedText = NSMutableAttributedString(string: currentSongs[indexPath.row].artist, attributes: strokeTextAttributes)
        songDescriptionDetail.isHidden = false
        selectedSong = indexPath.row
        let imageData = try? Data(contentsOf: currentSongs[indexPath.row].bgURL)
        if (imageData != nil) {
            let image = UIImage(data: imageData!)
            UIView.transition(with: songImageDetail,
                duration: 0.75,
                options: .transitionCrossDissolve,
                animations: { self.songImageDetail.image =  image},
                completion: nil)
            
        }
        for subview in difficultySelect.arrangedSubviews {
            subview.removeFromSuperview()
        }
        var index = 0
        for difficulty in currentSongs[indexPath.row].difficulties {
            let diffName = difficulty.difficultyName
            let button = UIButton(type: .custom)
            button.frame = CGRect(x: 0, y: 0, width: 150, height: 50)
            button.layer.cornerRadius = 0.01 * button.bounds.size.width
            button.setTitle(String(index) + ": " + diffName, for: UIControlState.normal)
            button.addTarget(self, action: #selector(start(identifier:)), for: .touchUpInside)
            button.backgroundColor = UIColor.darkGray
            difficultySelect.addArrangedSubview(button)
            index += 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "song", for: indexPath) as! SongSelectControllerCell
        cell.songTitle.attributedText = NSMutableAttributedString(string: currentSongs[indexPath.row].name, attributes: strokeTextAttributes)
        cell.songDescription.attributedText = NSMutableAttributedString(string: currentSongs[indexPath.row].artist,
            attributes: strokeTextAttributes)
        let imageData = try? Data(contentsOf: currentSongs[indexPath.row].bgURL)
        if (imageData != nil) {
            let image = UIImage(data: imageData!)
            cell.songImage.image = image
        }
        cell.songImage.frame.size.width = (cell.songImage.image?.size.width)! * (cell.songImage.frame.height/(cell.songImage.image?.size.height)!)
        return cell
    }
    
    @objc func start(identifier: UIButton!) {
        let difficultyToPlay = Int(String((identifier.currentTitle?.prefix(1))!))!
        GameScene.currentSong = currentSongs[selectedSong]
        GameScene.difficultyToPlay = difficultyToPlay
        self.performSegue(withIdentifier: "StartGame", sender: self)
    }
}

class SongSelectControllerCell : UITableViewCell {
    @IBOutlet weak var songImage: UIImageView!
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var songDescription: UILabel!
}

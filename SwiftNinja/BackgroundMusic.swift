//
//  BackgroundSound.swift
//  SwiftNinja
//
//  Created by Kenny Cason on 10/12/14.
//  Copyright (c) 2014 Kenny Cason. All rights reserved.
//

import AVFoundation

class BackgroundMusic {

    var backgroundMusicPlayer: AVAudioPlayer!
    var filename: String
    
    init(filename: String) {
        self.filename = filename
        
        let url = NSBundle.mainBundle().URLForResource(filename, withExtension: nil)
        if (url == nil) {
            println("Could not find file: \(filename)")
            return
        }
        
        var error: NSError? = nil
        backgroundMusicPlayer = AVAudioPlayer(contentsOfURL: url, error: &error)
        if backgroundMusicPlayer == nil {
            println("Could not create audio player: \(error!)")
            return
        }
        backgroundMusicPlayer.numberOfLoops = -1
        backgroundMusicPlayer.prepareToPlay()
    }
    
    func play() {
        stop()
        backgroundMusicPlayer.play()
    }
    
    func pause() {
        backgroundMusicPlayer.pause()
    }
    
    func stop() {
        backgroundMusicPlayer.stop()
    }

}
//
//  SSAVSound.swift
//  SparrowSwift
//
//  Created by cz on 12/28/15.
//  Copyright © 2015 cz. All rights reserved.
//

import UIKit
import AVFoundation

class SSAVSound: SSSound {
    var soundData: NSData? = nil;
    
    deinit
    {
        self.soundData = nil;
    }
    
    func initWithContentsOfFile(path: String, duration: Double) -> SSAVSound?
    {
        let fullPath = path;
        self.soundData = NSData(contentsOfFile: fullPath);
        self.duration = duration;
        return self;
    }
    
    //#pragma mark Methods
    
    func createPlayer() -> AVAudioPlayer?
    {
        do{
            let player = try AVAudioPlayer(data: self.soundData!);
            return player;
        } catch let error as NSError {
            print("Could not create AVAudioPlayer: \(error)")
            return nil;
        }
    }
    
    //#pragma mark SSSoundChannel
    
    override func createChannel() -> SSSoundChannel?
    {
        return SSAVSoundChannel().initWithSound(self);
    }
}

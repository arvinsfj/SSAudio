//
//  SSAVSoundChannel.swift
//  SparrowSwift
//
//  Created by cz on 12/28/15.
//  Copyright © 2015 cz. All rights reserved.
//

import UIKit
import AVFoundation

class SSAVSoundChannel: SSSoundChannel, AVAudioPlayerDelegate {
    var sound: SSAVSound?;
    var player: AVAudioPlayer?;
    var paused: Bool = false;
    
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self);
        self.player?.delegate = nil;
        self.sound = nil;
    }
    
    func initWithSound(sound:SSAVSound) -> SSSoundChannel?
    {
        self.sound = sound;
        super.volume = 1.0;
        super.loop = false;
        self.player = sound.createPlayer();
        self.player?.volume = SSAudioEngine.masterVolume;
        self.player?.delegate = self;
        self.player?.prepareToPlay();
        
        let nc = NSNotificationCenter.defaultCenter();
        nc.addObserver(self, selector: Selector("onMasterVolumeChanged:"), name: SSNotificationMasterVolumeChanged, object: nil);
        
        return self;
    }
    
    //#pragma mark SSSoundChannel
    
    override func play() -> Void
    {
        self.paused = false;
        self.player?.play();
    }
    
    override func pause() -> Void
    {
        self.paused = true;
        self.player?.pause();
    }
    
    override func stop() -> Void
    {
        self.paused = false;
        self.player?.stop();
        self.player!.currentTime = 0;
    }
    
    override var isPlaying:Bool{
        get{
            return (self.player?.playing)!;
        }
        set{}
    };
    
    /// Indicates if the sound is currently paused.
    override var isPaused:Bool{
        get{
            return self.paused && (self.player?.playing)!==false;
        }
        set{}
    };
    
    /// Indicates if the sound was stopped.
    override var isStopped:Bool{
        get{
            return self.paused==false && (self.player?.playing)!==false;
        }
        set{}
    };
    
    /// The duration of the sound in seconds.
    override var duration:Double{
        get{
            return (self.player?.duration)!;
        }
        set{}
    };
    
    /// The volume of the sound. Range: [0.0 - 1.0]
    override var volume:Float{
        didSet(value){
            super.volume = volume;
            self.player?.volume = volume * SSAudioEngine.masterVolume;
        }
    };
    
    /// Indicates if the sound should loop. Looping sounds don't dispatch COMPLETED events.
    override var loop:Bool{
        get{
            return self.player?.numberOfLoops < 0;
        }
        set(value){
            super.loop = loop;
            if(value){
                self.player?.numberOfLoops = -1;
            }else{
                self.player?.numberOfLoops = 0;
            }
        }
    };
    
    //#pragma mark AVAudioPlayerDelegate
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool)
    {
        print("dispatchEvent");
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "SSEventTypeCompleted", object: self));
    }
    
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer, error: NSError?)
    {
        print("Error during sound decoding: \(error)");
    }
    
    func audioPlayerBeginInterruption(player: AVAudioPlayer)
    {
        self.player?.pause();
    }

    func audioPlayerEndInterruption(player: AVAudioPlayer, withOptions flags: Int)
    {
        self.player?.play();
    }
    
    //#pragma mark Notifications
    
    func onMasterVolumeChanged(notification: NSNotification) -> Void
    {
        self.volume = super.volume;//need to think
    }
}

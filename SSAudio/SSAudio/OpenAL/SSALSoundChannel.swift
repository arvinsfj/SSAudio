//
//  SSALSoundChannel.swift
//  SparrowSwift
//
//  Created by cz on 12/28/15.
//  Copyright © 2015 cz. All rights reserved.
//

import UIKit
import OpenAL

class SSALSoundChannel: SSSoundChannel {
    var sound: SSALSound?;
    var sourceID: ALuint = 0;
    
    var startMoment: Double = 0.0;
    var pauseMoment: Double = 0.0;
    var interrupted: Bool = false;
    
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self);
        alSourceStop(sourceID);
        alSourcei(sourceID, AL_BUFFER, 0);
        alDeleteSources(1, &sourceID);
        sourceID = 0;
        sound = nil;
    }
    
    func initWithSound(sound:SSALSound) -> SSSoundChannel?
    {
        self.sound = sound;
        super.volume = 1.0;
        super.loop = false;
        
        self.startMoment = 0.0;
        self.pauseMoment = 0.0;
        self.interrupted = false;
        
        alGenSources(1, &sourceID);
        alSourcei(sourceID, AL_BUFFER, ALint(sound.bufferID));
        let errorCode = alGetError();
        if (errorCode != AL_NO_ERROR)
        {
            print("Could not create OpenAL source \(errorCode)");
            return nil;
        }
        
        let nc = NSNotificationCenter.defaultCenter();
        nc.addObserver(self, selector: Selector("onInterruptionBegan:"), name: SSNotificationAudioInteruptionBegan, object: nil);
        nc.addObserver(self, selector: Selector("onInterruptionEnded:"), name: SSNotificationAudioInteruptionEnded, object: nil);
        
        return self;
    }
    
    //#pragma mark SSSoundChannel
    
    override func play() -> Void
    {
        if (!self.isPlaying){
        
            let now = CACurrentMediaTime();
    
            if (pauseMoment != 0.0) // paused
            {
                startMoment += now - pauseMoment;
                pauseMoment = 0.0;
            }
            else // stopped
            {
                startMoment = now;
            }
    
            self.scheduleSoundCompletedEvent();
            alSourcePlay(sourceID);
        }
    }
    
    override func pause() -> Void
    {
        if (self.isPlaying){
            self.revokeSoundCompletedEvent();
            pauseMoment = CACurrentMediaTime();
            alSourcePause(sourceID);
        }
    }
    
    override func stop() -> Void
    {
        self.revokeSoundCompletedEvent();
        pauseMoment = 0.0;
        startMoment = 0.0;
        alSourceStop(sourceID);
    }
    
    override var isPlaying:Bool{
        get{
            var state: ALint = 0;
            alGetSourcei(sourceID, AL_SOURCE_STATE, &state);
            return state == AL_PLAYING;
        }
        set{}
    };
    
    /// Indicates if the sound is currently paused.
    override var isPaused:Bool{
        get{
            var state: ALint = 0;
            alGetSourcei(sourceID, AL_SOURCE_STATE, &state);
            return state == AL_PAUSED;
        }
        set{}
    };
    
    /// Indicates if the sound was stopped.
    override var isStopped:Bool{
        get{
            var state: ALint = 0;
            alGetSourcei(sourceID, AL_SOURCE_STATE, &state);
            return state == AL_STOPPED;
        }
        set{}
    };
    
    /// The duration of the sound in seconds.
    override var duration:Double{
        get{
            return (sound?.duration)!;
        }
        set{}
    };
    
    /// The volume of the sound. Range: [0.0 - 1.0]
    override var volume:Float{
        didSet(value){
            super.volume = volume;
            alSourcef(sourceID, AL_GAIN, volume * SSAudioEngine.masterVolume);
        }
    };
    
    /// Indicates if the sound should loop. Looping sounds don't dispatch COMPLETED events.
    override var loop:Bool{
        didSet(value){
            super.loop = loop;
            var kValue: ALint = 0;
            if(loop){
                kValue = 1;
            }
            alSourcei(sourceID, AL_LOOPING, kValue);
        }
    };
    
    //#pragma mark Events
    
    func scheduleSoundCompletedEvent() -> Void
    {
        if (startMoment != 0.0){
            let remainingTime = sound!.duration - (CACurrentMediaTime() - startMoment);
            self.revokeSoundCompletedEvent();
            if (remainingTime >= 0.0){
                self.performSelector(Selector("dispatchCompletedEvent"), withObject: nil, afterDelay: remainingTime);
            }
        }
    }
    
    func revokeSoundCompletedEvent() -> Void
    {
        NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: Selector("dispatchCompletedEvent"), object: nil);
    }
    
    func dispatchCompletedEvent() -> Void
    {
        if (self.loop==false){
            print("dispatchEvent");
            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "SSEventTypeCompleted", object: self));
        }
    }
    
    //#pragma mark Notifications
    
    func onInterruptionBegan(notification: NSNotification) -> Void
    {
        if (self.isPlaying){
            self.revokeSoundCompletedEvent();
            interrupted = true;
            pauseMoment = CACurrentMediaTime();
        }
    }
    
    func onInterruptionEnded(notification: NSNotification) -> Void
    {
        if (interrupted){
            startMoment += CACurrentMediaTime() - pauseMoment;
            pauseMoment = 0.0;
            interrupted = false;
            self.scheduleSoundCompletedEvent();
        }
    }

}

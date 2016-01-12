//
//  SSAudioEngine.swift
//  SparrowSwift
//
//  Created by cz on 12/28/15.
//  Copyright © 2015 cz. All rights reserved.
//

import UIKit
import AVFoundation
import OpenAL

//notifications

public let SSNotificationMasterVolumeChanged        = "SSNotificationMasterVolumeChanged";
public let SSNotificationAudioInteruptionBegan      = "SSNotificationAudioInteruptionBegan";
public let SSNotificationAudioInteruptionEnded      = "SSNotificationAudioInteruptionEnded";

//

public enum SSAudioSessionCategory : String {
    case SSAudioSessionCategory_AmbientSound        =   "ambi"
    case SSAudioSessionCategory_SoloAmbientSound    =   "solo"
    case SSAudioSessionCategory_MediaPlayback       =   "medi"
    case SSAudioSessionCategory_RecordAudio         =   "reca"
    case SSAudioSessionCategory_PlayAndRecord       =   "plar"
    case SSAudioSessionCategory_AudioProcessing     =   "proc"
}

class SSAudioEngine: NSObject {
    static var device : COpaquePointer? = nil;
    static var context : COpaquePointer? = nil;
    static var interrupted : Bool = false;
    static var masterVolume : Float = 1.0 {
        didSet(volume){
            alListenerf(AL_GAIN, volume);
            SSAudioEngine.postNotification(SSNotificationMasterVolumeChanged, obj: nil);
        }
    };
    
    //private
    private static var sessionInitialized : Bool = false;
    class func initAudioSession(category:SSAudioSessionCategory) -> Bool
    {
        if (!sessionInitialized){
            do{
                try AVAudioSession.sharedInstance().setActive(true);
            } catch let error as NSError {
                print("Could not create audio session: \(error)")
                return false;
            }
            sessionInitialized = true;
        }
        
        var avCategory : String? = nil;
        switch (category){
        case .SSAudioSessionCategory_AmbientSound:     avCategory = AVAudioSessionCategoryAmbient; break;
        case .SSAudioSessionCategory_AudioProcessing:  avCategory = AVAudioSessionCategoryAudioProcessing; break;
        case .SSAudioSessionCategory_MediaPlayback:    avCategory = AVAudioSessionCategoryMultiRoute; break;
        case .SSAudioSessionCategory_PlayAndRecord:    avCategory = AVAudioSessionCategoryPlayAndRecord; break;
        case .SSAudioSessionCategory_RecordAudio:      avCategory = AVAudioSessionCategoryRecord; break;
        case .SSAudioSessionCategory_SoloAmbientSound: avCategory = AVAudioSessionCategorySoloAmbient; break;
        }
        do{
            try AVAudioSession.sharedInstance().setCategory(avCategory!);
        } catch let error as NSError {
            print("Could not create audio category: \(error)")
            return false;
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("onInterruption:"), name: AVAudioSessionInterruptionNotification, object: nil);
        
        return true;
    }
    
    class func initOpenAL() -> Bool
    {
        alGetError(); // reset any errors
        device = alcOpenDevice(nil);
        if (device==nil){
            print("Could not open default OpenAL device");
            return false;
        }
        context = alcCreateContext(device!,nil);
        if (context==nil){
            print("Could not create OpenAL context for default device");
            return false;
        }
        let success = alcMakeContextCurrent(context!);
        if (success==ALCboolean(ALC_FALSE)){
            print("Could not set current OpenAL context");
            return false;
        }
        return true;
    }
    
    //pragma mark Methods
    
    class func start(category:SSAudioSessionCategory) -> Void
    {
        if(device==nil){
            if(SSAudioEngine.initAudioSession(category)){
                SSAudioEngine.initOpenAL();
            }
            NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("onAppActivated:"), name: UIApplicationDidBecomeActiveNotification, object: nil);
        }
    }
    
    class func start() -> Void
    {
        SSAudioEngine.start(.SSAudioSessionCategory_SoloAmbientSound);
    }
    
    class func stop() -> Void
    {
        NSNotificationCenter.defaultCenter().removeObserver(self);
        alcMakeContextCurrent(nil);
        if let ctx = context {
            alcDestroyContext(ctx);
        }
        if let dev = device {
            alcDestroyContext(dev);
        }
        do{
            try AVAudioSession.sharedInstance().setActive(false);
        } catch let error as NSError {
            print("Could not stop audio session: \(error)")
        }
        device = nil;
        context = nil;
        interrupted = false;
    }
    
    //pragma mark Notifications
    
    class func onInterruption(notification:NSNotification) -> Void
    {
        let info = notification.userInfo;
        let type = AVAudioSessionInterruptionType(rawValue: UInt(info![AVAudioSessionInterruptionTypeKey]!.intValue!))!;
        if (type == AVAudioSessionInterruptionType.Began){//begin
            self.beginInterruption();
        }else{//end
            let shouldResume = info![AVAudioSessionInterruptionOptionKey]!.boolValue!;
            if (shouldResume){
                self.endInterruption();
            }
        }
    }
    
    class func beginInterruption() -> Void
    {
        SSAudioEngine.postNotification(SSNotificationAudioInteruptionBegan, obj: nil);
        do{
            try AVAudioSession.sharedInstance().setActive(false);
        } catch let error as NSError {
            print("Could not stop audio session: \(error)")
        }
        alcMakeContextCurrent(nil);
        
        interrupted = true;
    }
    
    class func endInterruption() -> Void
    {
        interrupted = false;
        alcMakeContextCurrent(context!);
        alcProcessContext(context!);
        do{
            try AVAudioSession.sharedInstance().setActive(true);
        } catch let error as NSError {
            print("Could not create audio session: \(error)")
        }
        SSAudioEngine.postNotification(SSNotificationAudioInteruptionEnded, obj: nil);
    }
    
    class func onAppActivated(notification:NSNotification) -> Void
    {
        if (interrupted){
            self.endInterruption();
        }
    }
    
    class func postNotification(name:String, obj:AnyObject?) -> Void
    {
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: name, object: obj));
    }
}

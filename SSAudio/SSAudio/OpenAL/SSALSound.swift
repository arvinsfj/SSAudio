//
//  SSALSound.swift
//  SparrowSwift
//
//  Created by cz on 12/28/15.
//  Copyright © 2015 cz. All rights reserved.
//

import UIKit
import OpenAL

class SSALSound: SSSound {
    var bufferID:ALuint = 0;
    
    deinit
    {
        alDeleteBuffers(1, &bufferID);
        bufferID = 0;
    }
    
    func initWithData(data:UnsafePointer<Void>,size:UInt32,channels:Int,frequency:Int,duration:Double) ->SSALSound?
    {
        self.duration=duration;
        SSAudioEngine.start();
        let currentContext = alcGetCurrentContext();
        if (currentContext==nil)
        {
            print("Could not get current OpenAL context");
            return nil;
        }
        
        var errorCode:ALenum;
        
        alGenBuffers(1, &bufferID);
        errorCode = alGetError();
        if (errorCode != AL_NO_ERROR)
        {
            print("Could not allocate OpenAL buffer (%x)", errorCode);
            return nil;
        }
        
        let format = (channels > 1) ? AL_FORMAT_STEREO16 : AL_FORMAT_MONO16;
        
        alBufferData(bufferID, format, data, ALsizei(size), ALsizei(frequency));
        errorCode = alGetError();
        if (errorCode != AL_NO_ERROR)
        {
            print("Could not fill OpenAL buffer (%x)", errorCode);
            return nil;
        }
        return self;
    }
    
    override func createChannel() -> SSSoundChannel?
    {
        return SSALSoundChannel().initWithSound(self);
    }
}

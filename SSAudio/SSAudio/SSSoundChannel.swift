//
//  SSSoundChannel.swift
//  SparrowSwift
//
//  Created by cz on 12/28/15.
//  Copyright © 2015 cz. All rights reserved.
//

import UIKit

class SSSoundChannel: NSObject {
    /// Indicates if the sound is currently playing.
    var isPlaying:Bool{
        get{
            NSException.raise("SSExceptionAbstractMethod", format: "Override 'isPlaying' in subclasses.", arguments: getVaList([]));
            return false;
        }
        set{}
    };
    
    /// Indicates if the sound is currently paused.
    var isPaused:Bool{
        get{
            NSException.raise("SSExceptionAbstractMethod", format: "Override 'isPaused' in subclasses.", arguments: getVaList([]));
            return false;
        }
        set{}
    };
    
    /// Indicates if the sound was stopped.
    var isStopped:Bool{
        get{
            NSException.raise("SSExceptionAbstractMethod", format: "Override 'isStopped' in subclasses.", arguments: getVaList([]));
            return false;
        }
        set{}
    };
    
    /// The duration of the sound in seconds.
    var duration:Double{
        get{
            NSException.raise("SSExceptionAbstractMethod", format: "Override 'duration' in subclasses.", arguments: getVaList([]));
            return 0.0;
        }
        set{}
    };
    
    /// The volume of the sound. Range: [0.0 - 1.0]
    var volume:Float = 1.0;
    
    /// Indicates if the sound should loop. Looping sounds don't dispatch COMPLETED events.
    var loop:Bool = false;
    
    func play() -> Void
    {
        //
        NSException.raise("SSExceptionAbstractMethod", format: "Override 'play' in subclasses.", arguments: getVaList([]));
    }
    
    func stop() -> Void
    {
        //
        NSException.raise("SSExceptionAbstractMethod", format: "Override 'stop' in subclasses.", arguments: getVaList([]));
    }
    
    func pause() -> Void
    {
        //
        NSException.raise("SSExceptionAbstractMethod", format: "Override 'pause' in subclasses.", arguments: getVaList([]));
    }
}

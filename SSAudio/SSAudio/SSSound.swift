//
//  SSSound.swift
//  SparrowSwift
//
//  Created by cz on 12/28/15.
//  Copyright © 2015 cz. All rights reserved.
//

import UIKit
import AVFoundation
import OpenAL
import AudioToolbox

class SSSound: NSObject {
    var duration : Double = 0;
    
    deinit
    {
        duration = 0.0;
    }
    
    func initWithContentsOfFile(path:String) -> SSSound?
    {
        //
        let fullPath = path;
        var error:String? = nil;
        var fileID: AudioFileID = nil
        var soundBuffer:UnsafeMutablePointer<Void> = nil;
        var soundSize:UInt32 = 0;
        var soundChannels:Int = 0;
        var soundFrequency:Int = 0;
        var soundDuration:Double = 0.0;

        repeat{
            var result:OSStatus = noErr;
            result = AudioFileOpenURL(NSURL.fileURLWithPath(fullPath), AudioFilePermissions.ReadPermission, 0, &fileID);
            if (result != noErr){
                error = "could not read audio file \(Int(result))";
                break;
            }
            
            var fileFormat:AudioStreamBasicDescription=AudioStreamBasicDescription();
            var propertySize: UInt32 = UInt32(sizeof(AudioStreamBasicDescription));
            result = AudioFileGetProperty(fileID, kAudioFilePropertyDataFormat, &propertySize, &fileFormat);
            if (result != noErr){
                error = "could not read file format info \(Int(result))";
                break;
            }
            
            propertySize = UInt32(sizeof(Double));
            result = AudioFileGetProperty(fileID, kAudioFilePropertyEstimatedDuration,
                &propertySize, &soundDuration);
            if (result != noErr){
                error = "could not read sound duration \(Int(result))";
                break;
            }
            
            if (fileFormat.mFormatID != kAudioFormatLinearPCM){
                error = "sound file not linear PCM";
                break;
            }
            
            if (fileFormat.mChannelsPerFrame > 2){
                error = "more than two channels in sound file";
                break;
            }
            
            
            if (((fileFormat.mFormatID == kAudioFormatLinearPCM) && ((fileFormat.mFormatFlags & kAudioFormatFlagIsBigEndian) == kAudioFormatFlagsNativeEndian))==false)
            {
                error = "sounds must be little-endian";
                break;
            }
            
            if (!(fileFormat.mBitsPerChannel == 8 || fileFormat.mBitsPerChannel == 16)){
                error = "only files with 8 or 16 bits per channel supported";
                break;
            }
            
            var fileSize:UInt64 = 0;
            propertySize = UInt32(sizeof(UInt64));
            result = AudioFileGetProperty(fileID, kAudioFilePropertyAudioDataByteCount,
                &propertySize, &fileSize);
            if (result != noErr){
                error = "could not read sound file size \(Int(result))";
                break;
            }
            
            var dataSize:UInt32 = UInt32(fileSize);
            soundBuffer = malloc(Int(dataSize));
            if (soundBuffer==nil){
                error = "could not allocate memory for sound data";
                break;
            }
            
            
            result = AudioFileReadBytes(fileID, false, 0, &dataSize, soundBuffer);
            if (result == noErr){
                soundSize = dataSize;
                soundChannels = Int(fileFormat.mChannelsPerFrame);
                soundFrequency = Int(fileFormat.mSampleRate);
            }else{
                error = "could not read sound data \(Int(result))";
                break;
            }
        }while(false);
        
        AudioFileClose(fileID);
        
        var sound: SSSound? = nil;
        if let err = error {
            print("Sound will be played with AVAudioPlayer [Reason: \(err)]");
            sound = SSAVSound().initWithContentsOfFile(fullPath, duration: soundDuration);
        }else{
            print("Sound will be played with OpenAL");
            sound = SSALSound().initWithData(soundBuffer, size: soundSize, channels: soundChannels, frequency: soundFrequency, duration: soundDuration);
        }
        
        free(soundBuffer);
        
        return sound;
    }
    
    class func soundWithContentsOfFile(path:String) -> SSSound?
    {
        //
        return SSSound().initWithContentsOfFile(path);
    }
    
    func createChannel() -> SSSoundChannel?
    {
        //
        NSException.raise("SSExceptionAbstractMethod", format:"Override 'createChannel' in subclasses.", arguments:getVaList([]));
        return nil;
    }
    
    func getDuration() -> Double
    {
        NSException.raise("SSExceptionAbstractMethod", format:"Override 'duration' in subclasses.", arguments:getVaList([]));
        return 0.0;
    }
}

//
//  ViewController.swift
//  SSAudio
//
//  Created by cz on 1/12/16.
//  Copyright © 2016 cz. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var musicChannel: SSSoundChannel? = nil;
    var actionChannel: SSSoundChannel? = nil;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        SSAudioEngine.start();
        let fullPath=NSBundle.mainBundle().pathForResource("music", ofType: "aifc");
        let music: SSSound = SSSound.soundWithContentsOfFile(fullPath!)!;
        self.musicChannel = music.createChannel()!;
        self.musicChannel!.loop = true;
        self.musicChannel!.volume = 0.5;
        self.musicChannel!.play();
        
        let actionFullPath=NSBundle.mainBundle().pathForResource("sound0", ofType: "caf");
        let action: SSSound = SSSound.soundWithContentsOfFile(actionFullPath!)!;
        self.actionChannel = action.createChannel()!;
        self.actionChannel!.loop = false;
        self.actionChannel!.volume = 1;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func playbackClicked(sender: AnyObject) {
        self.actionChannel!.stop();
        self.actionChannel!.play();
    }
}


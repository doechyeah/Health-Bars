//
//  ViewController.swift
//  Health Bars
//
//  Created by Michael Lin on 2019-10-26.
//  Copyright © 2019 Michael Lin. All rights reserved.
//

import AudioKit
import AudioKitUI

import UIKit

class ViewController: UIViewController {
    //@IBOutlet var plot: AKNodeOutputPlot?
    
    var success: Bool = false

    var oscillator1 = AKOscillator()
    //var oscillator2 = AKOscillator()
    //var mixer = AKMixer()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //mixer = AKMixer(oscillator1, oscillator2)

        // Cut the volume in half since we have two oscillators
        //mixer.volume = 0.5
        AudioKit.output = oscillator1
        do {
            try AudioKit.start()
        } catch {
            AKLog("AudioKit did not start!")
        }
    }

    @IBAction func toggleSound(_ sender: UIButton) {
        if oscillator1.isPlaying {
            oscillator1.stop()
            //oscillator2.stop()
            sender.setTitle("Play Sine Waves", for: .normal)
        } else {
            oscillator1.frequency = random(in: 220 ... 880)
            oscillator1.start()
            //oscillator2.frequency = random(in: 220 ... 880)
            //oscillator2.start()
            sender.setTitle("Stop \(Int(oscillator1.frequency))Hz", for: .normal)
        }
    }

    @IBAction func unwindToStart(_ unwindSegue: UIStoryboardSegue) {
        //let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
    }
    
    @IBAction func gotoSecondView(_ sender: UIButton) {
        if success == false {
            performSegue(withIdentifier: "ID_gotoSecondView", sender: self)
        }
    }
    
}


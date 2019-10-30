//
//  ViewController.swift
//  Health Bars
//
//  Created by Michael Lin on 2019-10-26.
//  Copyright © 2019 Michael Lin. All rights reserved.
//

// Majority of AudioKit code in this file is taken from AudioKit examples Hello World and Microphone Analysis

import AudioKit
import AudioKitUI

import UIKit

class ViewController: UIViewController {
    
    //MARK: Constants
    let noteFrequencies = [16.35, 17.32, 18.35, 19.45, 20.6, 21.83, 23.12, 24.5, 25.96, 27.5, 29.14, 30.87]
    let noteNamesWithSharps = ["C", "C♯", "D", "D♯", "E", "F", "F♯", "G", "G♯", "A", "A♯", "B"]
    let noteNamesWithFlats = ["C", "D♭", "D", "E♭", "E", "F", "G♭", "G", "A♭", "A", "B♭", "B"]
    
    
    //MARK: Outlets
    @IBOutlet weak var frequencyLabel: UILabel!
    @IBOutlet weak var amplitudeLabel: UILabel!
    @IBOutlet weak var noteNameWithSharpsLabel: UILabel!
    @IBOutlet weak var noteNameWithFlatsLabel: UILabel!
    
    
    //MARK: Condition variables
    var success: Bool = false
    
    //MARK: AudioKit variables
    var oscillator1: AKOscillator!
    var mixer: AKMixer!
    
    var mic: AKMicrophone!
    var tracker: AKFrequencyTracker!
    var bandpassfilter: AKBandPassButterworthFilter!
    var silence: AKBooster!
    
    // called when view first gets loaded into memory
    override func viewDidLoad() {
        // debug
        NSLog("viewDidLoad")
        super.viewDidLoad()
    }
    
    // called when view appears fully
    override func viewDidAppear(_ animated: Bool) {
        // debug
        NSLog("viewDidAppear")
        super.viewDidAppear(animated)
        
        AKSettings.audioInputEnabled = true
        // workaround for bug in audiokit: https://github.com/AudioKit/AudioKit/issues/1799#issuecomment-506373157
        AKSettings.sampleRate = AudioKit.engine.inputNode.inputFormat(forBus: 0).sampleRate
        
        oscillator1 = AKOscillator()
        mixer = AKMixer()
        
        mic = AKMicrophone()
        // filter out non-vocal frequencies
        bandpassfilter = AKBandPassButterworthFilter(mic, centerFrequency: 800, bandwidth: 750)
        tracker = AKFrequencyTracker(bandpassfilter)
        // have to connect the frequencytracker to an output, or else it won't work
        silence = AKBooster(tracker, gain: 0)
        mixer = AKMixer(oscillator1, silence)
        
        // set mic input to first (may not be necessary)
        if let inputs = AudioKit.inputDevices {
            do {
                try AudioKit.setInputDevice(inputs[0])
                try mic.setDevice(inputs[0])
            } catch {
                AKLog("failed to get mic")
            }
        } else {
            AKLog("failed to get mic")
        }
        
        
        // Cut the volume in half since we have two oscillators
        mixer.volume = 0.5
        AudioKit.output = mixer
        do {
            try AudioKit.start()
        } catch {
            AKLog("AudioKit did not start!")
        }
        Timer.scheduledTimer(timeInterval: 0.1,
                             target: self,
                             selector: #selector(ViewController.updateUI),
                             userInfo: nil,
                             repeats: true)
        
        // debug
        NSLog("Done viewDidAppear")
        
    }
    
    // called with view disappears fully
    override func viewDidDisappear(_ animated: Bool) {
        // debug
        NSLog("viewDidDisappear")
        
        do {
            try AudioKit.stop()
        } catch {
            AKLog("AudioKit did not stop!")
        }
        
        // debug
        NSLog("Done viewDidDisappear")
    }
    
    // start/stop sine oscillator
    @IBAction func toggleSound(_ sender: UIButton) {
        if oscillator1.isPlaying {
            oscillator1.stop()
            //oscillator2.stop()
            sender.setTitle("Play Sine Waves", for: .normal)
        } else {
            oscillator1.frequency = 1000
            oscillator1.start()
            //oscillator2.frequency = random(in: 220 ... 880)
            //oscillator2.start()
            sender.setTitle("Stop \(Int(oscillator1.frequency))Hz", for: .normal)
        }
    }
    
    // unwind segue function, called from other views
    @IBAction func unwindToStart(_ unwindSegue: UIStoryboardSegue) {
        //let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
    }
    
    // action segue to conditionally go to second view
    @IBAction func gotoSecondView(_ sender: UIButton) {
        if success == false {
            performSegue(withIdentifier: "ID_gotoSecondView", sender: self)
        }
    }
    
    @objc func updateUI() {
        // debug
        NSLog("updateUI")
        
        if tracker.amplitude > 0.1 {
            frequencyLabel.text = String(format: "%0.1f", tracker.frequency)
            
            var frequency = Float(tracker.frequency)
            while frequency > Float(noteFrequencies[noteFrequencies.count - 1]) {
                frequency /= 2.0
            }
            while frequency < Float(noteFrequencies[0]) {
                frequency *= 2.0
            }
            
            var minDistance: Float = 10_000.0
            var index = 0
            
            for i in 0..<noteFrequencies.count {
                let distance = fabsf(Float(noteFrequencies[i]) - frequency)
                if distance < minDistance {
                    index = i
                    minDistance = distance
                }
            }
            let octave = Int(log2f(Float(tracker.frequency) / frequency))
            noteNameWithSharpsLabel.text = "\(noteNamesWithSharps[index])\(octave)"
            noteNameWithFlatsLabel.text = "\(noteNamesWithFlats[index])\(octave)"
        }
        amplitudeLabel.text = String(format: "%0.2f", tracker.amplitude)
    }
    
}


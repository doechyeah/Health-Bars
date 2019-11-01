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
    
    //MARK: Testing constants
    // make sure this is a frequency from pitch table
    let testingFreq: Float = 440.0
    
    //MARK: Constants
    let noteFrequencies = [16.35, 17.32, 18.35, 19.45, 20.6, 21.83, 23.12, 24.5, 25.96, 27.5, 29.14, 30.87]
    let noteNamesWithSharps = ["C", "C♯", "D", "D♯", "E", "F", "F♯", "G", "G♯", "A", "A♯", "B"]
    // note sustain period, have to manually adjust based on timer durations
    let noteSustainPeriodsForSuccess = 10
    
    //MARK: Outlets
    @IBOutlet weak var frequencyLabel: UILabel!
    @IBOutlet weak var amplitudeLabel: UILabel!
    @IBOutlet weak var noteNameWithSharpsLabel: UILabel!
    @IBOutlet weak var listenButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var timerTest: UILabel!
    @IBOutlet weak var matchPeriods: UILabel!
    
    var timerTestNum: Float = 0
    
    //MARK: Condition variables
    var success: Bool = false
    var noteSustainPeriods: Int = 0
    var currentPitchIndexToMatch: Int!
    var displayTimer: Timer!
    var listenTimer: Timer!
    var recordTimer: Timer!
    
    //MARK: AudioKit variables
    var oscillator1: AKOscillator!
    var mixer: AKMixer!
    
    var mic: AKMicrophone!
    var tracker: AKFrequencyTracker!
    var bandpassfilter: AKBandPassButterworthFilter!
    var silence: AKBooster!
    
    deinit {
        NSLog("deinit()")
    }
    
    // called when view first gets loaded into memory
    override func viewDidLoad() {
        // debug
        NSLog("viewDidLoad()")
        super.viewDidLoad()
        
        // debug
        NSLog("Done viewDidLoad()")
    }
    
    // called when view appears fully
    override func viewDidAppear(_ animated: Bool) {
        // debug
        NSLog("viewDidAppear()")
        super.viewDidAppear(animated)
        
        AKSettings.audioInputEnabled = true
        // workaround for bug in audiokit: https://github.com/AudioKit/AudioKit/issues/1799#issuecomment-506373157
        AKSettings.sampleRate = AudioKit.engine.inputNode.inputFormat(forBus: 0).sampleRate
        
        oscillator1 = AKOscillator()
        
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
        
        mixer.volume = 1
        
        //TODO: read pitch from filename/contents
        currentPitchIndexToMatch = findPitchFromFrequency(testingFreq).1
        
        AudioKit.output = mixer
        
        do {
            try AudioKit.start()
        } catch {
            AKLog("AudioKit did not start!")
        }
        
        // debug
        NSLog("Done viewDidAppear()")
        
    }
    
    // called with view disappears fully
    override func viewDidDisappear(_ animated: Bool) {
        // debug
        NSLog("viewDidDisappear()")
        
        if listenTimer != nil {
            listenTimer.invalidate()
            listenTimer = nil
        }
        
        do {
            try AudioKit.stop()
        } catch {
            AKLog("AudioKit did not stop!")
        }
        
        
        // debug
        NSLog("Done viewDidDisappear()")
    }
    
    // start/stop sine oscillator
    @IBAction func toggleSound(_ sender: UIButton) {
        toggleOscillator()
    }
    
    @objc func toggleOscillator() {
        if oscillator1.isPlaying {
            oscillator1.stop()
            //oscillator2.stop()
            listenButton.setTitle("Play Sine Waves", for: .normal)
            
            if listenTimer != nil {
                listenTimer.invalidate()
                listenTimer = nil
            }
            listenButton.isEnabled = true
            recordButton.isEnabled = true
            
        } else {
            oscillator1.frequency = Double(testingFreq)
            oscillator1.start()
            listenTimer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(ViewController.toggleOscillator), userInfo: nil, repeats: false)
            //oscillator2.frequency = random(in: 220 ... 880)
            //oscillator2.start()
            listenButton.setTitle("Stop \(Int(oscillator1.frequency))Hz", for: .normal)
            listenButton.isEnabled = false
        }
    }
    
    // start recording to match the pitch
    @IBAction func startRecording(_ sender: UIButton) {
        sender.isEnabled = false
        listenButton.isEnabled = false
        displayTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(ViewController.updateUI), userInfo: nil, repeats: true)
        //displayTimer.tolerance = 0.1
        recordTimer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(ViewController.stopRecord), userInfo: nil, repeats: false)
        //recordTimer.tolerance = 0.5
        // replaced with timer
        //DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(4000)) {
        //    self.stopRecord()
        //}
    }
    
    // unwind segue function, called from other views
    @IBAction func unwindToStart(_ unwindSegue: UIStoryboardSegue) {
        //let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
    }
    
    // action segue to conditionally go to second view
    @IBAction func gotoSecondView(_ sender: UIButton) {
        if success == true {
            performSegue(withIdentifier: "ID_gotoSuccess", sender: self)
        }
    }
    
    @objc func updateUI() {
        // debug
        //NSLog("updateUI()")
        
        amplitudeLabel.text = String(format: "%0.2f", tracker.amplitude)
        
        timerTestNum += 0.1
        timerTest.text = "\(timerTestNum)"
        matchPeriods.text = "\(noteSustainPeriods)"
        
        
        if tracker.amplitude > 0.1 {
            frequencyLabel.text = String(format: "%0.1f", tracker.frequency)
            
            let (octave, index) = findPitchFromFrequency(Float(tracker.frequency))
            
            noteNameWithSharpsLabel.text = findPitchFromOctaveIndexString(octave, index)
            
            matchPitch(index)
        }
    }
    
    // invalidate displayTimer to stop updating UI
    @objc func stopRecord() {
        if displayTimer != nil {
            displayTimer.invalidate()
            displayTimer = nil
        }
        if recordTimer != nil {
            recordTimer.invalidate()
            recordTimer = nil
        }
        // button doesn't appear enabled until UI is interacted with, but can still be pressed
        listenButton.isEnabled = true
        recordButton.isEnabled = true
        timerTestNum = 0
        timerTest.text = "TimerTest"
        matchPeriods.text = "MatchPeriods"
        
        if success == false {
            performSegue(withIdentifier: "ID_gotoFail", sender: self)
        } else if success == true {
            performSegue(withIdentifier: "ID_gotoSuccess", sender: self)
        }
    }
    
    func matchPitch(_ pitch: Int) {
        if currentPitchIndexToMatch == pitch {
            noteSustainPeriods += 1
        }
        if noteSustainPeriods >= noteSustainPeriodsForSuccess {
            noteSustainPeriods = 0
            success = true
            stopRecord()
        }
    }
    
    func findPitchFromFrequency(_ freq: Float) -> (Int, Int) {
        var frequency = freq
        
        // find base frequency
        while frequency > Float(noteFrequencies[noteFrequencies.count - 1]) {
            frequency /= 2.0
        }
        while frequency < Float(noteFrequencies[0]) {
            frequency *= 2.0
        }
        
        var minDistance: Float = 10_000.0
        var index = 0
        
        // find closest pitch match
        for i in 0..<noteFrequencies.count {
            let distance = fabsf(Float(noteFrequencies[i]) - frequency)
            if distance < minDistance {
                index = i
                minDistance = distance
            }
        }
        let octave = Int(log2f(freq / frequency))
        return (octave, index)
    }
    
    func findPitchFromFrequencyString(_ freq: Float) -> String {
        let (octave, index) = findPitchFromFrequency(Float(freq))
        return findPitchFromOctaveIndexString(octave, index)
    }
    
    func findPitchFromOctaveIndexString(_ octave: Int, _ index: Int) -> String {
        return "\(noteNamesWithSharps[index])\(octave)"
    }
    
}

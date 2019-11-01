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

class LongTones: UIViewController {
    
    //MARK: Testing constants
    // make sure this is a frequency from pitch table
    let testingFreq: Double = 440.0
    
    //MARK: Constants
    let noteFrequencies = [16.35, 17.32, 18.35, 19.45, 20.6, 21.83, 23.12, 24.5, 25.96, 27.5, 29.14, 30.87]
    let noteNamesWithSharps = ["C", "C♯", "D", "D♯", "E", "F", "F♯", "G", "G♯", "A", "A♯", "B"]
    // note sustain period, have to manually adjust based on timer durations
    let recordTimerInterval = 0.1
    let recordTimerPeriod = 4.0
    let noteSustainPeriodsForSuccess = 10
    
    //MARK: Outlets
    /*
    @IBOutlet weak var frequencyLabel: UILabel!
    @IBOutlet weak var amplitudeLabel: UILabel!
    @IBOutlet weak var noteNameWithSharpsLabel: UILabel!
    @IBOutlet weak var listenButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var timerTest: UILabel!
    @IBOutlet weak var matchPeriods: UILabel!
    */
    
    @IBOutlet weak var hearTheToneButton: UIButton!
    @IBOutlet weak var recordYourToneButton: UIButton!
    
    @IBOutlet weak var toneToMatchStaticText: UILabel!
    @IBOutlet weak var toneToMatchText: UILabel!
    @IBOutlet weak var currentToneStaticText: UILabel!
    @IBOutlet weak var currentToneText: UILabel!
    @IBOutlet weak var volumeStaticText: UILabel!
    @IBOutlet weak var volumeText: UILabel!
    @IBOutlet weak var progressStaticText: UILabel!
    @IBOutlet weak var progressText: UILabel!
    @IBOutlet weak var timerStaticText: UILabel!
    @IBOutlet weak var timerText: UILabel!
    
    
    var timerTestNum: Double!
    
    //MARK: Condition variables
    var success: Bool!
    var noteSustainPeriods: Int!
    var currentPitchIndexToMatch: Int!
    var displayTimer: Timer!
    var listenTimer: Timer!
    
    // special variable for keeping the sane tone when coming from fail screen
    //TODO:
    var segueKeepSameTone: Bool = false
    
    //MARK: AudioKit variables
    //TODO: get rid of this in favour of reading from file
    var oscillator1: AKOscillator!
    
    var mic: AKMicrophone!
    var tracker: AKFrequencyTracker!
    var bandpassfilter: AKBandPassButterworthFilter!
    var silence: AKBooster!
    var mixer: AKMixer!
    
    deinit {
        //debug
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
        
        // UI Init
        hearTheToneButton.isHidden = false
        hearTheToneButton.isEnabled = true
        
        if segueKeepSameTone == false {
            recordYourToneButton.isHidden = false
            recordYourToneButton.isEnabled = false
        
            toneToMatchStaticText.isHidden = true
            toneToMatchText.isHidden = true
            toneToMatchText.text = "__"
        }
        
        currentToneStaticText.isHidden = true
        currentToneText.isHidden = true
        currentToneText.text = "_"
        
        volumeStaticText.isHidden = true
        volumeText.isHidden = true
        volumeText.text = "__"
        
        progressStaticText.isHidden = true
        progressText.isHidden = true
        progressText.text = "__%"
        
        timerStaticText.isHidden = true
        timerText.isHidden = true
        timerText.text = String(format: "%0.2f", recordTimerPeriod)
        // end UI Init
        
        // condition variables init
        success = false
        noteSustainPeriods = 0
        timerTestNum = recordTimerPeriod
        //TODO: read pitch from filename/contents
        currentPitchIndexToMatch = findPitchFromFrequency(testingFreq).1
        
        
        // AudioKit variables init
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
        
        AudioKit.output = mixer
        // end AudioKit variables init
        
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
        
        // destroy timers
        destroyTimers()
        
        do {
            try AudioKit.stop()
        } catch {
            AKLog("AudioKit did not stop!")
        }
        
        // debug
        NSLog("Done viewDidDisappear()")
    }
    
    // start/stop sine oscillator
    /*
    @IBAction func toggleSound(_ sender: UIButton) {
        toggleOscillator()
    }
    */
    
    
    @IBAction func hearTheToneButtonPressed(_ sender: UIButton) {
        lockButtons()
        startOscillator()
        unhideToneToMatchTexts()
        NSLog(findPitchFromFrequencyString(testingFreq))
        toneToMatchText.text = findPitchFromFrequencyString(testingFreq)
        listenTimer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(LongTones.doneHearTheToneButtonPressed), userInfo: nil, repeats: false)
    }
    
    // start recording to match the pitch
    @IBAction func recordYourToneButtonPressed(_ sender: UIButton) {
        lockButtons()
        unhideRecordTexts()
        displayTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(LongTones.updateUI), userInfo: nil, repeats: true)
        //displayTimer.tolerance = 0.1
        // replaced with timer
        //DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(4000)) {
        //    self.stopRecord()
        //}
    }
    
    // unwind segue function, called from other views
    @IBAction func unwindToLongTones(_ unwindSegue: UIStoryboardSegue) {
        //let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
    }
    
    // action segue to conditionally go to second view
    @IBAction func gotoSuccess(_ sender: UIButton) {
        if success == true {
            performSegue(withIdentifier: "segue_gotoSuccess", sender: self)
        }
    }
    
    @objc func startOscillator() {
        oscillator1.frequency = Double(testingFreq)
        oscillator1.start()
    }
    
    @objc func stopOscillator() {
        oscillator1.stop()
    }
    
    @objc func doneHearTheToneButtonPressed() {
        if listenTimer != nil {
            listenTimer.invalidate()
            listenTimer = nil
        }
        stopOscillator()
        unlockButtons()
    }
    
    @objc func updateUI() {
        // debug
        NSLog("updateUI()")
        
        timerTestNum -= 0.1
        
        volumeText.text = String(format: "%0.2f", tracker.amplitude)
        
        timerText.text = "\(String(describing: timerTestNum))"
        //TODO: fix so it works for any number of periods
        progressText.text = String(format: "%.2f", Double(noteSustainPeriods)/10)
        
        
        if tracker.amplitude > 0.1 {
            
            let (_, index) = findPitchFromFrequency(Double(tracker.frequency))
            
            currentToneText.text = noteNamesWithSharps[index]
            
            matchPitch(index)
        }
        
        //replace with proper Double epsilon
        if (timerTestNum < 0.001) {
            stopRecord()
        }
    }
    
    // invalidate displayTimer to stop updating UI
    @objc func stopRecord() {
        //debug
        NSLog("stopRecord()")
        if displayTimer != nil {
            displayTimer.invalidate()
            displayTimer = nil
        }
        // button doesn't appear enabled until UI is interacted with, but can still be pressed
        unlockButtons()
        
        
        if success == false {
            performSegue(withIdentifier: "segue_gotoFail", sender: self)
        } else if success == true {
            performSegue(withIdentifier: "segue_gotoSuccess", sender: self)
        }
    }
    
    
    //MARK: helper functions
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
    
    func findPitchFromFrequency(_ freq: Double) -> (Int, Int) {
        var frequency = freq
        
        // find base frequency
        while frequency > Double(noteFrequencies[noteFrequencies.count - 1]) {
            frequency /= 2.0
        }
        while frequency < Double(noteFrequencies[0]) {
            frequency *= 2.0
        }
        
        var minDistance: Double = 10_000.0
        var index = 0
        
        // find closest pitch match
        for i in 0..<noteFrequencies.count {
            let distance = abs(Double(noteFrequencies[i]) - frequency)
            if distance < minDistance {
                index = i
                minDistance = distance
            }
        }
        let octave = Int(log2(freq / frequency))
        return (octave, index)
    }
    
    func findPitchFromFrequencyString(_ freq: Double) -> String {
        let (octave, index) = findPitchFromFrequency(Double(freq))
        return findPitchFromOctaveIndexString(octave, index)
    }
    
    func findPitchFromOctaveIndexString(_ octave: Int, _ index: Int) -> String {
        return "\(noteNamesWithSharps[index])\(octave)"
    }
    
    func destroyTimers() {
        if listenTimer != nil {
            listenTimer.invalidate()
            listenTimer = nil
        }
        if displayTimer != nil {
            displayTimer.invalidate()
            displayTimer = nil
        }
    }
    
    func lockButtons() {
        hearTheToneButton.isEnabled = false
        recordYourToneButton.isEnabled = false
    }
    
    func unlockButtons() {
        hearTheToneButton.isEnabled = true
        recordYourToneButton.isEnabled = true
    }
    
    func unhideToneToMatchTexts() {
        toneToMatchStaticText.isHidden = false
        toneToMatchText.isHidden = false
    }
    
    func unhideRecordTexts() {
        currentToneStaticText.isHidden = false
        currentToneText.isHidden = false
        
        volumeStaticText.isHidden = false
        volumeText.isHidden = false
        
        progressStaticText.isHidden = false
        progressText.isHidden = false
    }
}

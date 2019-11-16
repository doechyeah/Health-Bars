//  Health Bars
//
//  Team: Team Rhythm
//
//  LongTones.swift
//  Long Tones activity, play a tone and replicate the tone through user input.
//
//  Developers:
//  Michael Lin
//  Alvin David
//
//  Copyright © 2019 Team Rhythm. All rights reserved.
//
//  Changelog:
//  2019-10-27: Created
//  2019-10-28: Added frequency detection and pitch evaluation
//  2019-10-29: Converted to Xcode 10.3
//  2019-11-02: Added audio file playback
//
//  Bugs:
//  2019-11-03 Frequency detection can be slightly off, however works almost all of the time
//
// Majority of AudioKit code in this file is taken from AudioKit examples Hello World and Microphone Analysis

import AudioKit

import UIKit

class LongTones: UIViewController {
    
    //MARK: Constants
    let noteFrequencies = [16.35, 17.32, 18.35, 19.45, 20.6, 21.83, 23.12, 24.5, 25.96, 27.5, 29.14, 30.87]
    let noteNamesWithSharps = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    let playTonePeriod = 5.0
    // note sustain period, have to manually adjust based on timer durations
    let displayTimerInterval = 0.1
    let displayTimerPeriod = 5.0
    let noteSustainPeriodsForSuccess = 10
    
    //MARK: Outlets
    @IBOutlet weak var hearTheToneButton: UIButton!
    @IBOutlet weak var recordYourToneButton: UIButton!
    
    @IBOutlet weak var toneToMatchStaticText: UILabel!
    @IBOutlet weak var toneToMatchText: UILabel!
    @IBOutlet weak var currentToneStaticText: UILabel!
    @IBOutlet weak var currentToneText: UILabel!
    // debug text on UI
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
    
    // special variable for keeping the same tone when coming from fail screen
    var segueKeepSameTone: Bool = false
    var randNote: Int = Int.random(in: 0...11)
    var noteSame: Int = -1
    
    //MARK: AudioKit variables
    var note: AKAudioFile!
    var notePlayer: AKPlayer!
    
    var mic: AKMicrophone!
    var tracker: AKFrequencyTracker!
    var bandpassfilter: AKBandPassButterworthFilter!
    var silence: AKBooster!
    var mixer: AKMixer!
    
    deinit {
        //debug
        //NSLog("deinit()")
    }
    
    // called when view first gets loaded into memory
    override func viewDidLoad() {
        // debug
        NSLog("viewDidLoad()")
        super.viewDidLoad()
        
        // debug
        //NSLog("Done viewDidLoad()")
    }
    
    // called when view appears fully
    override func viewDidAppear(_ animated: Bool) {
        // debug
        NSLog("viewDidAppear()")
        super.viewDidAppear(animated)
        // simulator fix: https://stackoverflow.com/questions/48773526/ios-simulator-does-not-refresh-correctly/50685380
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        if(!segueKeepSameTone){
            randNote =  Int.random(in: 0...11)
            if (noteSame == randNote) {
                let x = randNote + Int.random(in: 1...11)
                randNote = x%12
            }
            noteSame = randNote
        }
        initPlayer()
        
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
        timerText.text = String(format: "%0.2f", displayTimerPeriod)
        // end UI Init
        
        // condition variables init
        success = false
        noteSustainPeriods = 0
        timerTestNum = displayTimerPeriod
        //read pitch from filename/contents
        currentPitchIndexToMatch = randNote
        
        // AudioKit variables init
        AKSettings.audioInputEnabled = true
        // workaround for bug in audiokit: https://github.com/AudioKit/AudioKit/issues/1799#issuecomment-506373157
        AKSettings.sampleRate = AudioKit.engine.inputNode.inputFormat(forBus: 0).sampleRate
        
        mic = AKMicrophone()
        // filter out non-vocal frequencies
        bandpassfilter = AKBandPassButterworthFilter(mic, centerFrequency: 800, bandwidth: 750)
        tracker = AKFrequencyTracker(bandpassfilter)
        // must to connect the frequencytracker to an output for functionality.
        silence = AKBooster(tracker, gain: 0)
        mixer = AKMixer(notePlayer, silence)
        
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
        
        AudioKit.output = mixer
        initAudioSession()
        // end AudioKit variables init
        
        // debug
        //NSLog("Done viewDidAppear()")
        
    }
    
    // called with view disappears fully
    override func viewDidDisappear(_ animated: Bool) {
        // debug
        NSLog("viewDidDisappear()")
        
        // destroy timers
        destroyTimers()
        
        do {
            try AudioKit.stop()
            mic.stop()
            AudioKit.disconnectAllInputs()
            mic.detach()
            bandpassfilter.detach()
            tracker.detach()
            silence.detach()
            mixer.detach()
            try AudioKit.shutdown()
            //debug
            AudioKit.printConnections()
            
        } catch {
            AKLog("AudioKit did not stop!")
        }
        
        // debug
        //NSLog("Done viewDidDisappear()")
    }
    
    @IBAction func hearTheToneButtonPressed(_ sender: UIButton) {
        lockButtons()
        notePlayer.play(from: 0.0)
        unhideToneToMatchTexts()
        toneToMatchText.text = noteNamesWithSharps[randNote]
        // let note play for 5 seconds
        listenTimer = Timer.scheduledTimer(timeInterval: playTonePeriod, target: self, selector: #selector(LongTones.doneHearTheToneButtonPressed), userInfo: nil, repeats: false)
    }
    
    // start recording to match the pitch
    @IBAction func recordYourToneButtonPressed(_ sender: UIButton) {
        lockButtons()
        unhideRecordTexts()
        // call updateUI every 0.1 seconds
        displayTimer = Timer.scheduledTimer(timeInterval: displayTimerInterval, target: self, selector: #selector(LongTones.updateUI), userInfo: nil, repeats: true)
        //displayTimer.tolerance = 0.1
    }
    
    // unwind segue function, called from other views
    @IBAction func unwindToLongTones(_ unwindSegue: UIStoryboardSegue) {
        //let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
    }
    
    @objc func doneHearTheToneButtonPressed() {
        if listenTimer != nil {
            listenTimer.invalidate()
            listenTimer = nil
        }
        notePlayer.stop()
        unlockButtons()
    }
    
    // updates current tone text and gets current mic input frequency
    @objc func updateUI() {
        // debug
        //NSLog("updateUI()")
        
        timerTestNum -= displayTimerInterval
        
        volumeText.text = String(format: "%0.2f", tracker.amplitude)
        
        timerText.text = String(format: "%0.2f",timerTestNum)
        //TODO: fix so it works for any number of periods
        progressText.text = String(format: "%.0f%%", Double(noteSustainPeriods)*10)
        
        
        var matched: Bool = false
        
        if tracker.amplitude > 0.1 {
            
            let (_, index) = findPitchFromFrequency(Double(tracker.frequency))
            
            currentToneText.text = noteNamesWithSharps[index]
            
            matched = matchPitch(index)
        }
        
        // TODO: replace with proper Double epsilon
        if (matched || timerTestNum < 0.001) {
            stopRecord()
        }
    }
    
    // invalidate displayTimer to stop updating UI
    @objc func stopRecord() {
        //debug
        //NSLog("stopRecord()")
        if displayTimer != nil {
            displayTimer.invalidate()
            displayTimer = nil
        }

        unlockButtons()
        
        if success == false {
            segueKeepSameTone = true
            performSegue(withIdentifier: "segue_gotoFailLongTones", sender: self)
        } else if success == true {
            segueKeepSameTone = false
            performSegue(withIdentifier: "segue_gotoSuccessLongTones", sender: self)
        }
    }
    
    //MARK: helper functions
    // check if input pitch is same as pitch to match
    func matchPitch(_ pitch: Int) -> Bool {
        if currentPitchIndexToMatch == pitch {
            noteSustainPeriods += 1
        }
        if noteSustainPeriods >= noteSustainPeriodsForSuccess {
            noteSustainPeriods = 0
            success = true
            return true
        }
        return false
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
    }
    
    //initializes the audio file to play
    func initPlayer() {
        do {
            try note = AKAudioFile(readFileName: noteNamesWithSharps[randNote]+".mp3", baseDir: .resources)
            notePlayer = AKPlayer(audioFile: note)
        } catch {
            //error
        }
    }
    
    //initializes audio session to play audio on device speakers
    func initAudioSession() {
        do {
            try AKSettings.session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.mixWithOthers)
            try AKSettings.session.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
            try AudioKit.start()
        } catch {
            //error
        }
    }
}

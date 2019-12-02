//  Health Bars
//
//  Team: Team Rhythm
//
//  LongTones.swift
//  Long Tones activity, app plays a tone and user must replicate that tone with their voice
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
//  2019-11-22: Refactored with new AudioKitConductor class
//
//  Bugs:
//  2019-11-03 Frequency detection can be slightly off, however works almost all of the time
//
//  Majority of AudioKit code in this file is taken from AudioKit examples Hello World and Microphone Analysis

import AudioKit

import UIKit

class LongTones: UIViewController, ProgressBarProtocol {
    
    //MARK: Constants
    let noteFrequencies = [16.35, 17.32, 18.35, 19.45, 20.6, 21.83, 23.12, 24.5, 25.96, 27.5, 29.14, 30.87]
    let noteNamesWithSharps = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    let playTonePeriod = 5.0
    // note sustain period, have to manually adjust based on timer durations
    let displayTimerInterval = 0.1
    let displayTimerPeriod = 5.0
    let noteSustainPeriodsForSuccess = 10
    
    //MARK: Shared AudioKit conductor
    let conductor = AudioKitConductor.sharedInstance
    
    //MARK: Database Score
    let PDB = ProgClass.sharedInstance
    
    
    //MARK: Outlets
    @IBOutlet weak var hearTheToneButton: UIButton!
    @IBOutlet weak var recordYourToneButton: UIButton!
    
    @IBOutlet weak var toneToMatchStaticText: UILabel!
    @IBOutlet weak var toneToMatchText: UILabel!
    @IBOutlet weak var currentToneStaticText: UILabel!
    @IBOutlet weak var currentToneText: UILabel!
    // debug text on UI
    //@IBOutlet weak var volumeStaticText: UILabel!
    //@IBOutlet weak var volumeText: UILabel!
    //@IBOutlet weak var progressStaticText: UILabel!
    //@IBOutlet weak var progressText: UILabel!
    //@IBOutlet weak var timerStaticText: UILabel!
    //@IBOutlet weak var timerText: UILabel!
    
    // if daily exercises, all exercises view controller has to set to .DailyExercises with prepare function before segue
    var activityMode: ActivityMode = ._none
    var activity: Activity = .LongTones
    var dailyExercisesDoneToday: [Bool] = [false, false, false]
    
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
    var songFile: AKAudioFile!
    
    
    deinit {
        //debug
        //NSLog("deinit()")
    }
    
    
    func unwindSegueFromView() {
        NSLog("Long Tones delegate unwind function")
        performSegue(withIdentifier: "segue_unwindtoNavigationMenu", sender: self)
    }
    @IBOutlet weak var progressBar: ProgressBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressBar.delegate = self
        //TODO: pass data that was sent from AllExercises
        progressBar.setVars(new_activityMode: .AllExercises, new_currentActivity: .LongTones, new_titleText: "LONG TONES")
    }
    
    // called when view appears fully
    override func viewWillAppear(_ animated: Bool) {
        // debug
        NSLog("viewDidAppear()")
        super.viewDidAppear(animated)
        // simulator fix: https://stackoverflow.com/questions/48773526/ios-simulator-does-not-refresh-correctly/50685380
        //UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        dailyExercisesDoneToday = PDB.readDAct()
        progressBar.setCompletedActivities(activitiesCompleted: dailyExercisesDoneToday)
        
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
        
        //volumeStaticText.isHidden = true
        //volumeText.isHidden = true
        //volumeText.text = "__"
        
        //progressStaticText.isHidden = true
        //progressText.isHidden = true
        //progressText.text = "__%"
        
        //timerStaticText.isHidden = true
        //timerText.isHidden = true
        //timerText.text = String(format: "%0.2f", displayTimerPeriod)
        // end UI Init
        
        // condition variables init
        success = false
        noteSustainPeriods = 0
        timerTestNum = displayTimerPeriod
        //read pitch from filename/contents
        currentPitchIndexToMatch = randNote
        
        // debug
        //NSLog("Done viewDidAppear()")
        
    }
    
    // called with view disappears fully
    override func viewDidDisappear(_ animated: Bool) {
        // debug
        NSLog("viewDidDisappear()")
        
        // destroy timers
        destroyTimers()
        
        conductor.stop()
        //conductor.resetPlayer()
        
        // debug
        //NSLog("Done viewDidDisappear()")
    }
    
    // send data with segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        NSLog("long tones prepare()")
        NSLog(segue.destination.debugDescription)
        if let vc = segue.destination as? Success {
            NSLog("is Success")
            vc.activityMode = activityMode
            vc.activity = activity
        }
        if let vc = segue.destination as? Fail {
            NSLog("is Fail")
            vc.activityMode = activityMode
            vc.activity = activity
        }
    }
    
    @IBAction func hearTheToneButtonPressed(_ sender: UIButton) {
        lockButtons()
        conductor.prerollPlayer(from: 0.0, to: playTonePeriod)
        conductor.play()
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
        conductor.stop()
        unlockButtons()
    }
    
    // updates current tone text and gets current mic input frequency
    @objc func updateUI() {
        // debug
        //NSLog("updateUI()")
        
        timerTestNum -= displayTimerInterval
        
        //volumeText.text = String(format: "%0.2f", tracker.amplitude)
        
        //timerText.text = String(format: "%0.2f",timerTestNum)
        //TODO: fix so it works for any number of periods
        //progressText.text = String(format: "%.0f%%", Double(noteSustainPeriods)*10)
        
        
        var matched: Bool = false
        
        if conductor.tracker.amplitude > 0.1 {
            
            let (_, index) = findPitchFromFrequency(Double(conductor.tracker.frequency))
            
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
        
        updateStats()
        
        if success == false {
            segueKeepSameTone = true
            performSegue(withIdentifier: "segue_gotoFailLongTones", sender: self)
        } else if success == true {
            segueKeepSameTone = false
            performSegue(withIdentifier: "segue_gotoSuccessLongTones", sender: self)
        }
    }
    
    //MARK: helper functions
    
    // save stats to our DB
    func updateStats() {
        // 0 is fail, 1 is success
        var activityScore = 0
        if success {
            activityScore = 1
        }
        PDB.insert(table: "voice", actscore: activityScore)
        PDB.dumpAll()
    }
    
    // check if input pitch is same as pitch to match
    func matchPitch(_ pitch: Int) -> Bool {
        if currentPitchIndexToMatch == pitch {
            noteSustainPeriods += 1
            print(String(noteSustainPeriods))
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
        NSLog("Long Tones initPlayer()")
        do {
            try songFile = AKAudioFile(readFileName: noteNamesWithSharps[randNote]+".mp3", baseDir: .resources)
            conductor.loadFile(my_file: songFile)
        } catch {
            NSLog("error in initPlayer()")
        }
    }
}

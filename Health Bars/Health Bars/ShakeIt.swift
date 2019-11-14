//  Health Bars
//
//  Team: Team Rhythm
//
//  ShakeIt.swift
//  Shake It activity, play a song and user shakes to beat. Collects data on accuracy of shakes vs beat
//
//  Developers:
//  Michael Lin
//
//  Copyright © 2019 Team Rhythm. All rights reserved.
//
//  Changelog:
//  2019-11-05: Created
//
//  Bugs:
//

import UIKit

import AudioKit

class ShakeIt: UIViewController {

    //MARK: Constants
    let playSongPeriod: Double = 20.0
    // UI update time interval resolution
    let displayTimerInterval: Double = 0.1
    let beatMatchRatioForSuccess: Double = 0.5
    // tolerance of accuracy of shake to beat as percentage of beat period, from center to edge (not negative to positive edge)
    let shakeAccuracyToleranceRatio: Double = 0.3
    let countdownLength: Int = 5
    
    let tempo: [String: Int] = ["Grave": 25,
                                "Lento": 45,
                                "Adagio": 66,
                                "Andante": 76,
                                "Moderato": 108,
                                "Allegro": 112,
                                "Vivace": 156,
                                "Presto": 168]

    // Metronome
    //let met = AKMetronome()

    //MARK: Outlets
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var pretendShakeButton: UIButton!
    @IBOutlet weak var amplitudeLabel: UILabel!
    @IBOutlet weak var countdownLabel: UILabel!
    

    //MARK: Condition variables
    var success: Bool!
    var shakeBeatHits: Int!
    var shakeBeatMisses: Int!
    var shakeBeatOffTempos: Int!
    var displayTimer: Timer!
    var beatTimer: Timer!
    var countdownNum: Int!
    
    var shakedToBeat: Bool = false
    var beatNum: Int = 0
    
    var songBPM: Double!
    var songStartOffsetTime: Double!
    var songBeatPeriod: Double!
    var shakeAccuracyToleranceTime: Double!
    var gameActive: Bool!

    // special variable for keeping the same song when coming from fail screen
    var segueKeepSameSong: Bool = false

    //MARK: AudioKit variables
    var songFile: AKAudioFile!
    var songPlayer: AKPlayer!
    var amplitudeTracker: AKAmplitudeTracker!


    // Note: Anything faster than Allegro is pretty dumb to do.


    deinit {
        //debug
        //NSLog("deinit()")
    }

    override func becomeFirstResponder() -> Bool {
        return true
    }
    
    // called by system when start of motion gesture has been detected
    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            print("Shake event from shake gesture")
            shakeEvent()
        }
    }
    

    // called when view first gets loaded into memory
    override func viewDidLoad() {
        // debug
        //NSLog("viewDidLoad()")
        super.viewDidLoad()

        // debug
        //NSLog("Done viewDidLoad()")
    }

    // called when view appears fully
    override func viewDidAppear(_ animated: Bool) {
        // debug
        //NSLog("viewDidAppear()")
        super.viewDidAppear(animated)
        // simulator fix: https://stackoverflow.com/questions/48773526/ios-simulator-does-not-refresh-correctly/50685380
        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        // UI Init
        amplitudeLabel.text = "Amplitude"
        countdownLabel.text = "Countdown"
        // end UI Init

        // condition variables init
        success = false
        shakeBeatHits = 0
        shakeBeatMisses = 0
        shakeBeatOffTempos = 0
        displayTimer = nil
        beatTimer = nil
        countdownNum = countdownLength
        
        //TODO: implement
        //chooseSong(tempoMin: minTempo, tempoMax: maxTempo)
        songBPM = 154.0
        songStartOffsetTime = 0.0
        songBeatPeriod = 60 / songBPM
        shakeAccuracyToleranceTime = shakeAccuracyToleranceRatio * songBeatPeriod
        NSLog("shakeAccuracyToleranceTime: \(shakeAccuracyToleranceTime!)")
        
        gameActive = false
        
        // AudioKit variables init
        // init (preload) player on view load so starting is faster
        initPlayer()

        initAudioSession()
        // end AudioKit variables init

        // debug
        //NSLog("Done viewDidAppear()")
    }
    
    /*
    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }
 */

    // called with view disappears fully
    override func viewDidDisappear(_ animated: Bool) {
        // debug
        //NSLog("viewDidDisappear()")
        super.viewDidDisappear(animated)

        // destroy timers
        //destroyTimers()
        endGame()

        songPlayer.stop()

        do {
            try AudioKit.stop()
        } catch {
            AKLog("AudioKit did not stop!")
        }

        // debug
        //NSLog("Done viewDidDisappear()")
    }

    //MARK: Actions
    @IBAction func startButtonPressed(_ sender: UIButton) {
        startButton.isEnabled = false
        countdownStart()
    }
        

    @IBAction func pretendShakePressed(_ sender: UIButton) {
        //print("Shake event from Pretend shake button")
        shakeEvent()
    }

    // unwind segue function, called from other views
    @IBAction func unwindToShakeIt(_ unwindSegue: UIStoryboardSegue) {
        //let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
    }

    // updates current tone text and gets current mic input frequency
    @objc func updateUI() {
        // debug
        //NSLog("updateUI()")
        amplitudeLabel.text = "\(amplitudeTracker.amplitude)"

    }

    //MARK: helper functions
    @objc func countdownStart() {
        NSLog("Countdown: \(countdownNum ?? -1)")
        countdownNum -= 1
        if countdownNum >= 0 {
            Timer.scheduledTimer(timeInterval: 1.0,
                                            target: self,
                                            selector: #selector(ShakeIt.countdownStart),
                                            userInfo: nil,
                                            repeats: false)
        } else {
            startGame()
        }
    }
    
    func startGame() {
        NSLog("Start Game!")
        displayTimer = Timer.scheduledTimer(timeInterval: displayTimerInterval,
                                            target: self,
                                            selector: #selector(ShakeIt.updateUI),
                                            userInfo: nil,
                                            repeats: true)
        
        // have trigger right before start of each good hit window
        Timer.scheduledTimer(withTimeInterval: songStartOffsetTime + (2 * songBeatPeriod) - shakeAccuracyToleranceTime, repeats: false, block: {_ in
            self.beatTimer = Timer.scheduledTimer(timeInterval: self.songBeatPeriod,
                                             target: self,
                                             selector: #selector(ShakeIt.updateShakeCondition),
                                             userInfo: nil,
                                             repeats: true)
        })
        
        // can also achieve with separate timer
        songPlayer.completionHandler = {
            self.endGame()
        }
        //TODO: use songOffsetTime maybe?
        songPlayer.play(from: 0.0, to: playSongPeriod)
        gameActive = true
    }
    
    func endGame() {
        NSLog("End Game!")
        gameActive = false
        shakedToBeat = false
        destroyTimers()
        updateStats()
    }
    
    // display/save stats to our DB (IF WE HAD ONE)
    func updateStats() {

    }
    
    func destroyTimers() {
        if displayTimer != nil {
            displayTimer.invalidate()
            displayTimer = nil
        }
        if beatTimer != nil {
            beatTimer.invalidate()
            beatTimer = nil
        }
    }

    //TODO: make async if necessary (testing required)
    @objc func updateShakeCondition() {
        //NSLog("updateShakeCondition()")
        if !shakedToBeat {
            shakeBeatMisses += 1
        }
        shakedToBeat = false
        beatNum += 1
        //print("Time discrepancy vs AKPlayer: \((beatNum * songBeatPeriod) - songPlayer.currentTime)")
    }
    
    func shakeEvent() {
        //debug
        //NSLog("shakeEvent()")
        if gameActive {
            //NSLog("Current song time: \(songPlayer.currentTime)")
            // good shake timing window calculation
            let offset: Double = (songPlayer.currentTime - songStartOffsetTime).remainder(dividingBy: songBeatPeriod)
            NSLog("\(offset)")
            if abs(offset) < shakeAccuracyToleranceTime && !shakedToBeat{
                shakeBeatHits += 1
                shakedToBeat = true
                NSLog("shake Hit")
            } else {
                shakeBeatOffTempos += 1
                NSLog("shake Off Tempo")
            }
        } else {
            NSLog("Game not started yet")
        }
    }
    

    //initializes the audio file to play
    //TODO: choose random file and read song properties file, probably make another function
    func initPlayer() {
        do {
            try songFile = AKAudioFile(readFileName: "songTest_Hardbass.mp3", baseDir: .resources)
            songPlayer = AKPlayer(audioFile: songFile)

            if songPlayer.duration < playSongPeriod {
                NSLog("song is \(songPlayer.duration) but playback duration is \(playSongPeriod)")
            }
            songPlayer.prepare()
        } catch {
            //error
        }
    }

    //initializes audio session to play audio on device speakers
    func initAudioSession() {
        do {
            // workaround for bug in audiokit: https://github.com/AudioKit/AudioKit/issues/1799#issuecomment-506373157
            AKSettings.sampleRate = AudioKit.engine.inputNode.inputFormat(forBus: 0).sampleRate

            amplitudeTracker = AKAmplitudeTracker(songPlayer)

            AudioKit.output = amplitudeTracker
            //try AKSettings.session.setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.mixWithOthers)
            try AKSettings.session.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
            try AudioKit.start()
        } catch {
            //error
        }
    }



    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

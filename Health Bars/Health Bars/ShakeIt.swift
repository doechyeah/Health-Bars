//
//  ShakeIt.swift
//  Health Bars
//
//  Created by Michael Lin on 2019-11-11.
//  Copyright © 2019 Team Rhythm. All rights reserved.
//

import UIKit
import AudioToolbox

import AudioKit

class ShakeIt: UIViewController {

    //MARK: Constants
    let playSongPeriod = 20.0
    // UI update time interval resolution
    let displayTimerInterval = 0.1
    let beatMatchRatioForSuccess = 0.5
    
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


    //MARK: Condition variables
    var success: Bool!
    var beatMatchHits: Int!
    var beatMatchMisses: Int!
    var displayTimer: Timer!
    
    
    var songBPM: Float!
    var songStartOffsetTime: Float!

    // special variable for keeping the same song when coming from fail screen
    var segueKeepSameSong: Bool = false

    //MARK: AudioKit variables
    var songFile: AKAudioFile!
    var songPlayer: AKAudioPlayer!
    var amplitudeTracker: AKAmplitudeTracker!


    //var BeatsPlay: Int!
    //var totBeats: Int!
    //var timeInterv: Int!
    // Note: Anything faster than Allegro is pretty dumb to do.
    var gameActive = false
    var score = 0
    var timeOfLastShake = 0
    var timer = Timer()


    deinit {	
        //debug
        //NSLog("deinit()")
    }

    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
//            print("SHAKE!")
            if !gameActive {
                gameActive = true
                if songPlayer != nil {
                    if songPlayer.isStarted {
                        print("\(songPlayer.currentTime)")
                    
                    }
                }
            }
            else {
                timeOfLastShake = score
            }
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

        //let randomTempo = tempo.randomElement()
        
        //BeatsPlay = randomTempo!.value
        
        // Lets assume we lets them play for 30 seconds?
        //totBeats = BeatsPlay/2
        //timeInterv = (60/BeatsPlay)*1000
        

        // UI Init

        // end UI Init

        // condition variables init
        success = false
        beatMatchHits = 0
        beatMatchMisses = 0
        displayTimer = nil
        
        //TODO:
        songBPM = 154.0
        songStartOffsetTime = 1.0
        
        // read pitch from filename/contents
        
        //TODO: implement
        //chooseSong(tempoMin: minTempo, tempoMax: maxTempo)
        
        
        // init (preload) player on view load so starting is faster
        initPlayer()

        // AudioKit variables init
        initAudioSession()
        // end AudioKit variables init

        // debug
        //NSLog("Done viewDidAppear()")
    
    }
    
    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }

    // called with view disappears fully
    override func viewDidDisappear(_ animated: Bool) {
        // debug
        //NSLog("viewDidDisappear()")

        // destroy timers
        destroyTimers()

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
        displayTimer = Timer.scheduledTimer(timeInterval: displayTimerInterval,
                                            target: self,
                                            selector: #selector(ShakeIt.updateUI),
                                            userInfo: nil,
                                            repeats: true)
        //debug
        
        songPlayer.completionHandler = {
            self.donePlayback()
        }
        songPlayer.play(from: 0.0, to: playSongPeriod)
        
        gameActive = true
        
        /*
        for x in 1...totBeats {
            // Show visual cue here.
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            // TRIGGER ACCURACY FUNCTION HERE
            usleep(useconds_t(timeInterv))
            var accSoFar: Double = beatMatchHits/x
            print(accSoFar)
            
        }
 */
        
    }


    @IBAction func pretendShakePressed(_ sender: UIButton) {
        print("\(songPlayer.currentTime)")
    }

    // unwind segue function, called from other views
    @IBAction func unwindToShakeIt(_ unwindSegue: UIStoryboardSegue) {
        //let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
    }
    
    @objc func updateScore() {
        score += 1
//        scoreLabel.text = String(score)
        let timeSinceLastShake = score - timeOfLastShake
//        switch timeSinceLastShake {
//        case 1:
//            messageLabel.Text = "Perfect"
//        case 2:
//            messageLabel.Text = "Good"
//        case 3:
//            messageLabel.Text = "Okay"
//        default:
//            messageLabel.Text = "Miss"
//        }
    }

    // updates current tone text and gets current mic input frequency
    @objc func updateUI() {
        // debug
        //NSLog("updateUI()")
        amplitudeLabel.text = "\(amplitudeTracker.amplitude)"

    }

    func donePlayback() {
        self.destroyTimers()
        AKLog("Done playback")
        startButton.isEnabled = true
        amplitudeLabel.text = "Amplitude"
    }


    //MARK: helper functions
    func destroyTimers() {
        if displayTimer != nil {
            displayTimer.invalidate()
            displayTimer = nil
        }
    }


    //initializes the audio file to play
    func initPlayer() {
        do {
            try songFile = AKAudioFile(readFileName: "songTest_Hardbass.mp3", baseDir: .resources)
            try songPlayer = AKAudioPlayer(file: songFile!)

            if songPlayer.duration < playSongPeriod {
                NSLog("song is \(songPlayer.duration) but playback duration is \(playSongPeriod)")
            }
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

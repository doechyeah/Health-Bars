//
//  ShakeIt.swift
//  Health Bars
//
//  Created by Michael Lin on 2019-11-11.
//  Copyright © 2019 Team Rhythm. All rights reserved.
//

import UIKit

import AudioKit

class ShakeIt: UIViewController {

    //MARK: Constants
    let playSongPeriod = 20.0
    // UI update time interval resolution
    let displayTimerInterval = 0.1
    let beatMatchRatioForSuccess = 0.5
    // Metronome
    let met = AKMetronome()

    //MARK: Outlets
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var pretendShakeButton: UIButton!
    @IBOutlet weak var amplitudeLabel: UILabel!


    //MARK: Condition variables
    var success: Bool!
    var beatMatchHits: Int!
    var beatMatchMisses: Int!
    var displayTimer: Timer!

    // special variable for keeping the same song when coming from fail screen
    var segueKeepSameSong: Bool = false

    //MARK: AudioKit variables
    var songFile: AKAudioFile!
    var songPlayer: AKAudioPlayer!
    var amplitudeTracker: AKAmplitudeTracker!

    //MARK: Tempo variable
    let tempo: [String: Int] = ["Grave": 25, "Lento": 45, "Adagio": 66, "Andante": , "Moderato", "Allegro", "Vivace", "Presto"]
    // Note: Anything faster than Allegro is pretty dumb to do.


    deinit {
        //debug
        //NSLog("deinit()")
    }



    func BeatScore() {
        Timer
    }

    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
          print("Good")
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

        /*
        if(!segueKeepSameTone){
            randNote =  Int.random(in: 0...11)
            if (noteSame == randNote) {
                let x = randNote + Int.random(in: 1...11)
                randNote = x%12
            }
            noteSame = randNote
        }
        */

        // UI Init

        // end UI Init

        // condition variables init
        success = false
        beatMatchHits = 0
        beatMatchMisses = 0
        displayTimer = nil
        //read pitch from filename/contents
        initPlayer()

        // AudioKit variables init
        initAudioSession()
        // end AudioKit variables init

        // debug
        //NSLog("Done viewDidAppear()")

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
        displayTimer = Timer.scheduledTimer(timeInterval: displayTimerInterval, target: self, selector: #selector(ShakeIt.updateUI), userInfo: nil, repeats: true)
        //debug

        songPlayer.completionHandler = {
            self.donePlayback()
        }
        songPlayer.play(from: 0.0, to: playSongPeriod)
    }


    @IBAction func pretendShakePressed(_ sender: UIButton) {
        print("\(songPlayer.currentTime)")
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

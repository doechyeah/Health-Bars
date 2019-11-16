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
//  2019-11-15: NSTimer will drift slightly on simulator, results in accuracy drift, should not matter with shorter song durations
//

import UIKit

import AudioKit

class ShakeIt: UIViewController {


    //MARK: Constants
    // UI update time interval resolution
    let displayTimerInterval: Double = 0.1
    let beatMatchRatioForSuccess: Double = 0.5
    // tolerance of accuracy of shake to beat as percentage of beat period, from center to edge (not negative to positive edge)
    let shakeAccuracyToleranceRatio: Double = 0.2
    let countdownLength: Int = 3
    
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
    //MARK: Game parameters
    var shakeBeatHits: Int = 0
    var shakeBeatMisses: Int = 0
    var shakeBeatOffTempos: Int = 0
    
    var countdownNum: Int = 0
    
    var songName: String = ""
    var songUrl: URL!
    
    var gameActive: Bool = false
    
    var shakedToBeat: Bool = false
    var beatNum: Int = 0
    
    var songStartOffsetTime: Double = 0
    var songEndTime: Double = 0
    var playSongPeriod: Double = 0
    var songBPM: Double = 0
    var songBeatPeriod: Double = 0
    var shakeAccuracyToleranceTime: Double = 0
    
    var success: Bool = false
    
    // Mutex
    let shakeLck = NSLock()

    // special variable for keeping the same song when coming from fail screen
    var segueKeepSameSong: Bool = false

    var displayTimer: Timer!
    var beatTimer: Timer!
    
    //MARK: AudioKit variables
    var songFile: AKAudioFile!
    var songPlayer: AKPlayer!
    var amplitudeTracker: AKAmplitudeTracker!
    
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
        // game parameters init
        shakeBeatHits = 0
        shakeBeatMisses = 0
        shakeBeatOffTempos = 0
        
        countdownNum = countdownLength
        
        songName = ""
        
        gameActive = false
        
        shakedToBeat = false
        beatNum = 0
        
        songStartOffsetTime = 0
        songEndTime = 0
        playSongPeriod = 0
        songBPM = 0
        songBeatPeriod = 0
        shakeAccuracyToleranceTime = 0
        
        success = false
        //end game parameters init
        
        
        // condition variables init
        displayTimer = nil
        beatTimer = nil
        
        //TODO: implement
        //chooseSong(tempoMin: minTempo, tempoMax: maxTempo)
        
        chooseRandomSong()
        // AudioKit variables init
        // init (preload) player on view load so starting is faster
        initPlayer()
        
        initAudioSession()
        // end AudioKit variables init
        
        setGameParameters()
        
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

    @objc func countdownStart() {
        if countdownNum > 0 {
            print("Countdown: \(countdownNum)")
            countdownNum -= 1
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
        print("Start Game!")
        
        displayTimer = Timer.scheduledTimer(timeInterval: displayTimerInterval,
                                            target: self,
                                            selector: #selector(ShakeIt.updateUI),
                                            userInfo: nil,
                                            repeats: true)
        
        // have trigger right at end of first window
        DispatchQueue.global(qos: .background).async {
            let ti = Timer.scheduledTimer(withTimeInterval: self.songStartOffsetTime + self.shakeAccuracyToleranceTime, repeats: false, block: {_ in
                self.beatTimer = Timer.scheduledTimer(timeInterval: self.songBeatPeriod,
                target: self,
                selector: #selector(ShakeIt.updateShakeCondition),
                userInfo: nil,
                repeats: true)
            })
            let runLoop = RunLoop.current
            runLoop.add(ti, forMode: .default)
            runLoop.run()
        }
        
        // can also achieve with separate timer
        songPlayer.completionHandler = {
            self.endGame()
        }
        //TODO: use songOffsetTime maybe?
        songPlayer.play(at: AVAudioTime.now())
    }
    
    func endGame() {
        print("End Game!")
        shakeLck.lock()
        gameActive = false
        shakedToBeat = false
        destroyTimers()
        updateStats()
        shakeLck.unlock()
    }
    
    // display/save stats to our DB (IF WE HAD ONE)
    func updateStats() {
        //TODO:
        print("Hits: \(shakeBeatHits)")
        print("Misses: \(shakeBeatMisses)")
        print("Off Tempos: \(shakeBeatOffTempos)")
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
        shakeLck.lock()
        if !shakedToBeat {
            shakeBeatMisses += 1
            print("shake Miss")
        }
        shakedToBeat = false
        beatNum += 1
        print("Beatnum: \(beatNum)")
        //print("Time discrepancy vs AKPlayer: \((beatNum * songBeatPeriod) - songPlayer.currentTime)")
        shakeLck.unlock()
    }
    
    func shakeEvent() {
        //debug
        //NSLog("shakeEvent()")
        if gameActive {
            //NSLog("Current song time: \(songPlayer.currentTime)")
            // good shake timing window calculation
            shakeLck.lock()
            let currentTime = songPlayer.currentTime
            let offset: Double = (songPlayer.currentTime - songStartOffsetTime).remainder(dividingBy: songBeatPeriod)
            print("offset: \(offset)\ncurrent player time: \(currentTime)")
            if abs(offset) < shakeAccuracyToleranceTime && !shakedToBeat{
                shakeBeatHits += 1
                shakedToBeat = true
                print("shake Hit")
            } else {
                shakeBeatOffTempos += 1
                print("shake Off Tempo")
            }
            shakeLck.unlock()
        } else {
            print("Game not started yet")
        }
    }
    
    
    //initializes the audio file to play
    //TODO: choose random file and read song properties file, probably make another function
    func initPlayer() {
        do {
            
            try songFile = AKAudioFile(forReading: songUrl)
            songPlayer = AKPlayer(audioFile: songFile)
            
            if songPlayer.duration < playSongPeriod {
                // should never happen
                print("song is \(songPlayer.duration) but playback duration is \(playSongPeriod)")
            }
            
            // less than 0 for play until end
            if songEndTime < 0 {
                songEndTime = songPlayer.duration
            }
            print("song playtime duration: \(songEndTime)")
            
            // preload file into memory for fast starting
            songPlayer.preroll(from: 0.0, to: songEndTime)
            
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
    
    func chooseRandomSong() {
        guard let urls = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: nil) else {
            //TODO: pop up message and exit game here
            NSLog("json urls array empty")
            return
        }
        songUrl = urls[Int.random(in: 0..<urls.count)]
        loadSongJsonParameters(url: songUrl)
    }
    
    func loadSongJsonParameters(url: URL) {
        let jsonString = try? String(contentsOf: url)
        let json = JSON(parseJSON: jsonString!)
        //debug
        for (key, subJson):(String, JSON) in json {
            print("\(key): \(subJson)")
        }
        //print("\(json["songName"])")
        songName = json["songName"].stringValue
        //TODO: maybe support for different extensions/formats
        songUrl = Bundle.main.url(forResource: songName, withExtension: "mp3")
        
        //print("\(json["BPM"])")
        songBPM = json["BPM"].doubleValue
        
        //print("\(json["endTime"])")
        songEndTime = json["endTime"].doubleValue
        
        //print("\(json["offsetStartTime"])")
        songStartOffsetTime = json["offsetStartTime"].doubleValue
        
        
        
    }
    
    func setGameParameters() {
        
        songBeatPeriod = 60.0 / songBPM
        shakeAccuracyToleranceTime = shakeAccuracyToleranceRatio * songBeatPeriod
        print("shakeAccuracyToleranceTime: \(shakeAccuracyToleranceTime)")
        playSongPeriod = songEndTime - songStartOffsetTime
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

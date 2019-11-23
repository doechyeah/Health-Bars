//  Health Bars
//
//  Team: Team Rhythm
//
//  ShakeIt.swift
//  Shake It activity, play a song and user shakes to beat. Collects data on accuracy of shakes vs beat
//
//  Developers:
//  Michael Lin
//  Daniel Song
//
//  Copyright © 2019 Team Rhythm. All rights reserved.
//
//  Changelog:
//  2019-11-05: Created
//  2019-11-14: Added asynchronous timers
//  2019-11-22: Refactored with new AudioKitConductor class
//
//  Bugs:
//  2019-11-15: NSTimer will drift slightly on simulator, results in accuracy drift, should not matter with shorter song durations
//  2019-11-15: Database write sometimes does not occur
//  2019-11-18: If using AirPods and you pull out (auto-pause) then vibrate detection no longer works.

import UIKit

import AudioToolbox
import AudioKit

class ShakeIt: UIViewController {

    //MARK: Constants
    let beatMatchRatioForSuccess: Double = 0.5
    // tolerance of accuracy of shake to beat as percentage of beat period, from center to edge (not negative to positive edge)
    let shakeAccuracyToleranceRatio: Double = 0.3
    let countdownLength: Int = 3
    
    //MARK: Shared AudioKit conductor
    let conductor = AudioKitConductor.sharedInstance
    
    //MARK: Database class
    let PDB = ProgClass(playID: "Player1")
    
    // Not used currently
    let tempo: [String: Int] = ["Grave": 25,
                                "Lento": 45,
                                "Adagio": 66,
                                "Andante": 76,
                                "Moderato": 108,
                                "Allegro": 112,
                                "Vivace": 156,
                                "Presto": 168]


    //MARK: Outlets
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var countdownLabel: UILabel!
    //debug
    @IBOutlet weak var hitsLabel: UILabel!
    @IBOutlet weak var missesLabel: UILabel!
    @IBOutlet weak var offTempoLabel: UILabel!
    @IBOutlet weak var imgvAvatar: UIImageView!

    
    //MARK: Game parameters
    var shakeBeatHits: Int = 0
    var shakeBeatMisses: Int = 0
    var shakeBeatOffTempos: Int = 0
    
    var countdownNum: Int = 0
    
    var jsonUrl: URL!
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
    
    // Animation
    var pulseLayers = [CAShapeLayer]()

    // special variable for keeping the same song when coming from fail screen
    var segueKeepSameSong: Bool = false

    var beatDisplayTimer: Timer!
    var beatResetTimer: Timer!
    
    var vibrationGenerator: UIImpactFeedbackGenerator!
    
    //MARK: AudioKit variables
    var songFile: AKAudioFile!
    
    deinit {
        //debug
        //NSLog("deinit()")
    }
    
    // required for responding to shake gestures, not needed for iOS 8.0 and above
    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }
    
    // called by system when start of motion gesture has been detected
    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            print("Shake event from shake gesture")
            shakeEvent()
        }
    }
    
    // send data with segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? Success {
            vc.
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
    override func viewWillAppear(_ animated: Bool) {
        // debug
        //NSLog("viewDidAppear()")
        super.viewDidAppear(animated)
        // simulator fix: https://stackoverflow.com/questions/48773526/ios-simulator-does-not-refresh-correctly/50685380
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        // UI Init
        countdownLabel.text = "Countdown"
        hitsLabel.text = "Hits"
        missesLabel.text = "Misses"
        offTempoLabel.text = "off Tempo"
        // end UI Init
        // game parameters init
        shakeBeatHits = 0
        shakeBeatMisses = 0
        shakeBeatOffTempos = 0
        
        countdownNum = countdownLength
        
        gameActive = false
        
        shakedToBeat = false
        beatNum = 0
        
        songName = ""
        
        success = false
        
        if segueKeepSameSong == false {
            songStartOffsetTime = 0
            songEndTime = 0
            playSongPeriod = 0
            songBPM = 0
            songBeatPeriod = 0
            shakeAccuracyToleranceTime = 0
        }
        
        //end game parameters init
        
        
        // condition variables init
        beatDisplayTimer = nil
        beatResetTimer = nil
        
        vibrationGenerator = UIImpactFeedbackGenerator(style: .heavy)
        
        //TODO: implement
        //chooseSong(tempoMin: minTempo, tempoMax: maxTempo)
        
        if segueKeepSameSong == false {
            chooseRandomSong()
        }
        // AudioKit variables init
        initPlayer()
        
        // end AudioKit variables init
        
        if segueKeepSameSong == false {
            setGameParameters()
        }

        // debug
        //NSLog("Done viewDidAppear()")
    }

    // called with view disappears fully
    override func viewDidDisappear(_ animated: Bool) {
        // debug
        //NSLog("viewDidDisappear()")
        super.viewDidDisappear(animated)

        // destroy timers
        destroyTimers()
        //endGame()

        conductor.stop()

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

    // unwind segue function, called from other views
    @IBAction func unwindToShakeIt(_ unwindSegue: UIStoryboardSegue) {
        //let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
    }

    @objc func countdownStart() {
        countdownLabel.text = "\(countdownNum)"
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
        countdownLabel.text = "Game Started!"
        
        // have trigger right at end of first window
        DispatchQueue.global(qos: .userInitiated).async {
            let ti = Timer.scheduledTimer(withTimeInterval: self.songStartOffsetTime + self.shakeAccuracyToleranceTime, repeats: false, block: {_ in
                self.updateShakeCondition()
                self.beatResetTimer = Timer.scheduledTimer(timeInterval: self.songBeatPeriod,
                target: self,
                selector: #selector(ShakeIt.updateShakeCondition),
                userInfo: nil,
                repeats: true)
            })
            let runLoop = RunLoop.current
            runLoop.add(ti, forMode: .default)
            runLoop.run()
        }
        
        // vibration
        self.vibrateOnBeat()
        self.beatDisplayTimer = Timer.scheduledTimer(timeInterval: self.songBeatPeriod,
                                              target: self,
                                              selector: #selector(ShakeIt.vibrateOnBeat),
                                              userInfo: nil,
                                              repeats: true)
//
        // can also achieve with separate timer
        conductor.player.completionHandler = {
            self.endGame()
        }
        conductor.player.play()
        NSLog("starttime: \(conductor.player.currentTime)")
        gameActive = true
    }
    
    func endGame() {
        print("End Game!")
        shakeLck.lock()
        gameActive = false
        shakedToBeat = false
        destroyTimers()
        updateStats()
        shakeLck.unlock()
        
        startButton.isEnabled = true
        
        if success == false {
            segueKeepSameSong = true
            performSegue(withIdentifier: "segue_gotoFailShakeIt", sender: self)
        } else if success == true {
            segueKeepSameSong = false
            performSegue(withIdentifier: "segue_gotoSuccessShakeIt", sender: self)
        }
    }
    
    // display/save stats to our DB
    func updateStats() {
        var scrd = 0
        if shakeBeatHits/(shakeBeatHits+shakeBeatMisses) > beatMatchRatioForSuccess {
            success = true
            scrd = 1
        }
        PDB.insert(table: "rhythm", actscore: scrd)
        print("Hits: \(shakeBeatHits)")
        print("Misses: \(shakeBeatMisses)")
        print("Off Tempos: \(shakeBeatOffTempos)")
        let debugdict = PDB.readTable(table: "rhythm")
        dump(debugdict)
        let statchck = PDB.readStats()
        dump(statchck)
    }
    
    func destroyTimers() {
        if beatDisplayTimer != nil {
            beatDisplayTimer.invalidate()
            beatDisplayTimer = nil
        }
        if beatResetTimer != nil {
            beatResetTimer.invalidate()
            beatResetTimer = nil
        }
    }
    
    @objc func updateShakeCondition() {
        //NSLog("updateShakeCondition()")
        shakeLck.lock()
        if !shakedToBeat {
            shakeBeatMisses += 1
            print("shake Miss")
        }
        shakedToBeat = false
        beatNum += 1
        //NSLog("Beatnum: \(beatNum)")
        //print("Time discrepancy vs AKPlayer: \((beatNum * songBeatPeriod) - songPlayer.currentTime)")
        shakeLck.unlock()
    }
    
//    Will Implement later. Coming in V3
    @objc func vibrateOnBeat() {
        //debug
        //print("Vibrate!")
        //vibrationGenerator.impactOccurred()
        NSLog("vibrateOnBeat()")
        //AudioServicesPlaySystemSound(1520)
        //AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        //AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        //createPulse()
    }
    
    func shakeEvent() {
        //debug
        //NSLog("shakeEvent()")
        if gameActive {
            // good shake timing window calculation
            shakeLck.lock()
            let currentTime = conductor.player.currentTime
            let offset: Double = (currentTime - songStartOffsetTime).remainder(dividingBy: songBeatPeriod)
            print("offset: \(offset)\ncurrent player time: \(currentTime)\nbeatNumAtShake: \(beatNum)")
            
            if abs(offset) < shakeAccuracyToleranceTime && !shakedToBeat{
                shakeBeatHits += 1
                shakedToBeat = true
                print("shake Hit")
                vibrationGenerator.impactOccurred()
                hitsLabel.text = "\(shakeBeatHits)"
            } else {
                shakeBeatOffTempos += 1
                print("shake Off Tempo")
                offTempoLabel.text = "\(shakeBeatOffTempos)"
            }
            missesLabel.text = "\(shakeBeatMisses)"
            shakeLck.unlock()
        } else {
            print("Game not started yet")
        }
    }
    
    
    //initializes the audio file to play
    func initPlayer() {
        NSLog("Shake It initPlayer()")
        do {
            try songFile = AKAudioFile(forReading: songUrl)
            conductor.loadFile(my_file: songFile)
            if conductor.player.duration < playSongPeriod {
                // should never happen
                print("song is \(conductor.player.duration) but playback duration is \(playSongPeriod)")
            }
            // less than 0 for play until end
            if songEndTime < 0 {
                songEndTime = conductor.player.duration
            }
            print("song playtime duration: \(songEndTime)")
            
            conductor.prerollPlayer(from: songStartOffsetTime, to: songEndTime)
            
        } catch {
            NSLog("error in initPlayer()")
        }
    }
    
    func chooseRandomSong() {
        guard let urls = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: nil) else {
            //TODO: pop up message and exit game here
            NSLog("json urls array empty")
            return
        }
        jsonUrl = urls[Int.random(in: 0..<urls.count)]
        loadSongJsonParameters(url: jsonUrl)
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
    
//    func createPulse() {
//        for _ in 0...2 {
//            let circularPath = UIBezierPath(arcCenter: .zero, radius: UIScreen.main.bounds.size.width/2.0, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
//            let pulseLayer = CAShapeLayer()
//            pulseLayer.path = circularPath.cgPath
//            pulseLayer.lineWidth = 2.0
//            pulseLayer.fillColor = UIColor.clear.cgColor
//            pulseLayer.lineCap = CAShapeLayerLineCap.round
//            pulseLayer.position = CGPoint(x: imgvAvatar.frame.size.width/2.0, y: imgvAvatar.frame.size.width/2.0)
//            imgvAvatar.layer.addSublayer(pulseLayer)
//            pulseLayers.append(pulseLayer)
//        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//            self.animatePulse(index: 0)
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
//                self.animatePulse(index: 1)
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                    self.animatePulse(index: 2)
//                }
//            }
//        }
//    }
//
//    func animatePulse(index: Int) {
//        pulseLayers[index].strokeColor = UIColor.black.cgColor
//
//        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
//        scaleAnimation.duration = 2.0
//        scaleAnimation.fromValue = 0.0
//        scaleAnimation.toValue = 0.9
//        scaleAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
//        scaleAnimation.repeatCount = .greatestFiniteMagnitude
//        pulseLayers[index].add(scaleAnimation, forKey: "scale")
//
//        let opacityAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
//        opacityAnimation.duration = 2.0
//        opacityAnimation.fromValue = 0.9
//        opacityAnimation.toValue = 0.0
//        opacityAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
//        opacityAnimation.repeatCount = .greatestFiniteMagnitude
//        pulseLayers[index].add(opacityAnimation, forKey: "opacity")
//
//
//
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//  Health Bars
//
//  Team: Team Rhythm
//
//  GuessThatInstrument.swift
//  Guess That Instrument activity, play a musical instrument clip, and user selects correct instrument from 4 options
//
//  Developers:
//  Alvin David
//  Trevor Chow
//
//  Copyright © 2019 Team Rhythm. All rights reserved.
//
//  Changelog:
//  2019-11-14: Created
//
// Bugs:
// 11-18-2019: If unable to access Audio then the app crashes.


import UIKit
import AudioKit

class GuessThatInstrument: UIViewController {
    @IBOutlet weak var playInstrumentButton: UIButton!
    @IBOutlet weak var instrumentButton1: UIButton!
    @IBOutlet weak var instrumentButton2: UIButton!
    @IBOutlet weak var instrumentButton3: UIButton!
    @IBOutlet weak var instrumentButton4: UIButton!
    
    @IBOutlet weak var instrumentImage1: UIImageView!
    @IBOutlet weak var instrumentImage2: UIImageView!
    @IBOutlet weak var instrumentImage3: UIImageView!
    @IBOutlet weak var instrumentImage4: UIImageView!
    
    let instrumentNames = ["clarinet","flute","sax","snare","trombone","trumpet","violin","piano","bells"]
    
    var segueKeepSameinstrument: Bool!
    var randInstrumentNumber: Int!
    var correctInstrumentNumber: Int!
    var correctInstrumentString: String!
    var randInstruments = ["instrument1","instrument2","instrument3","instrument4"]
    
    //MARK: Audio Player Variables
    var instrument: AKAudioFile!
    var instrumentPlayer: AKAudioPlayer!
    
    let PDB = ProgClass(playID: "Player1")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //load for the first time in memory
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // simulator fix: https://stackoverflow.com/questions/48773526/ios-simulator-does-not-refresh-correctly/50685380
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        // choose random instrument clips to present
        var set = [0,1,2,3,4,5,6,7,8]
        for index in 0...3 {
            randInstrumentNumber = set.randomElement()
            randInstruments[index] = instrumentNames[randInstrumentNumber]
            set.removeAll(where: { $0 == randInstrumentNumber } )
            //NSLog(set.debugDescription)
        }
        
        // choose correct instrument out of these 4
        correctInstrumentNumber = Int.random(in: 0...3)
        correctInstrumentString = randInstruments[correctInstrumentNumber]
        
        instrumentImage1.image = UIImage(named: randInstruments[0])
        instrumentImage2.image = UIImage(named: randInstruments[1])
        instrumentImage3.image = UIImage(named: randInstruments[2])
        instrumentImage4.image = UIImage(named: randInstruments[3])
        
        initPlayer()
        initAudioSession()
    }
    
    override func viewDidDisappear(_ animated: Bool){
        instrumentPlayer.stop()
        
        do {
            try AudioKit.stop()
        } catch {
            AKLog("AudioKit did not stop!")
        }

    }
    
    @IBAction func unwindToGTI(_ unwindSegue: UIStoryboardSegue) {}
    
    @IBAction func playInstrumentButtonPressed(_ sender: UIButton) {
        instrumentPlayer.play(from: 0.0)
        
    }
    
    //MARK: Instrument buttons
    @IBAction func instrumentButton1Pressed(_ sender: UIButton) {
        checkCorrect(0)
    }
    
    @IBAction func instrumentButton2Pressed(_ sender: UIButton) {
        checkCorrect(1)
    }
    
    @IBAction func instrumentButton3Pressed(_ sender: UIButton) {
        checkCorrect(2)
    }
    
    @IBAction func instrumentButton4Pressed(_ sender: UIButton) {
        checkCorrect(3)
    }
    
    func checkCorrect(_ choice: Int) {
        if(correctInstrumentString == randInstruments[choice]) {
            segueKeepSameinstrument = false
            PDB.insert(table: "memory", actscore: 1)
            let debugdict = PDB.readTable(table: "memory")
            dump(debugdict)
            let statchck = PDB.readStats()
            dump(statchck)
            NSLog("Correct")
            performSegue(withIdentifier: "segue_gotoSuccessGuessThatInstrument", sender: self)
        } else {
            //goto fail
            PDB.insert(table: "memory", actscore: 0)
            let debugdict = PDB.readTable(table: "memory")
            dump(debugdict)
            let statchck = PDB.readStats()
            dump(statchck)
            segueKeepSameinstrument = true
            NSLog("False")
            performSegue(withIdentifier: "segue_gotoFailGuessThatInstrument", sender: self)
        }
    }
    
    //initializes the audio file to play
    func initPlayer() {
        do {
            try instrument = AKAudioFile(readFileName: correctInstrumentString+".mp3", baseDir: .resources)
            try instrumentPlayer = AKAudioPlayer(file: instrument!)
        } catch {
            //error
        }
    }
    
    
    func initAudioSession() {
        do {
            // workaround for bug in audiokit: https://github.com/AudioKit/AudioKit/issues/1799#issuecomment-506373157
            AKSettings.sampleRate = AudioKit.engine.inputNode.inputFormat(forBus: 0).sampleRate
            AudioKit.output = instrumentPlayer
            try AKSettings.session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.mixWithOthers)
            try AKSettings.session.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
            try AudioKit.start()
        } catch {
            //error
        }
}

}

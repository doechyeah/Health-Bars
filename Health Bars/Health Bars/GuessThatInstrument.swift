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
//  Michael Lin
//
//  Copyright © 2019 Team Rhythm. All rights reserved.
//
//  Changelog:
//  2019-11-14: Created
//  2019-11-22: Refactored with new AudioKitConductor class
//
//  Bugs:
//  2019-11-18: If unable to access Audio then the app crashes.


import UIKit
import AudioKit

class GuessThatInstrument: UIViewController, ProgressBarProtocol {
    
    //MARK: Shared AudioKit conductor
    let conductor = AudioKitConductor.sharedInstance
    
    //MARK: Database class
    let PDB = ProgClass.sharedInstance
    
    //MARK: Constants
    let instrumentNames = ["clarinet","flute","sax","snare","trombone","trumpet","violin","piano","bells"]
    
    //MARK: Outlets
    @IBOutlet weak var playInstrumentButton: UIButton!
    @IBOutlet weak var instrumentButton1: UIButton!
    @IBOutlet weak var instrumentButton2: UIButton!
    @IBOutlet weak var instrumentButton3: UIButton!
    @IBOutlet weak var instrumentButton4: UIButton!
    
    @IBOutlet weak var instrumentImage1: UIImageView!
    @IBOutlet weak var instrumentImage2: UIImageView!
    @IBOutlet weak var instrumentImage3: UIImageView!
    @IBOutlet weak var instrumentImage4: UIImageView!
    
    var activityMode: ActivityMode = ._none
    var activity: Activity = .GuessThatInstrument
    var dailyExercisesDoneToday: [Bool] = [false, false, false]
    
    //MARK: Game variables
    var segueKeepSameinstrument: Bool!
    var randInstrumentNumber: Int!
    var correctInstrumentNumber: Int!
    var correctInstrumentString: String!
    var randInstruments = ["instrument1","instrument2","instrument3","instrument4"]
    var success: Bool = false
    
    //MARK: Audio Player Variables
    var instrument: AKAudioFile!
    //var instrumentPlayer: AKAudioPlayer!
    
    
    func unwindSegueFromView() {
        NSLog("GTI delegate unwind function")
        performSegue(withIdentifier: "segue_unwindtoNavigationMenu", sender: self)
    }
    @IBOutlet weak var progressBar: ProgressBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressBar.delegate = self
        //TODO: pass data that was sent from AllExercises
        progressBar.setVars(new_activityMode: .AllExercises, new_currentActivity: .GuessThatInstrument, new_titleText: "GUESS THAT INSTRUMENT")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // simulator fix: https://stackoverflow.com/questions/48773526/ios-simulator-does-not-refresh-correctly/50685380
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        dailyExercisesDoneToday = PDB.readDAct()
        progressBar.setCompletedActivities(activitiesCompleted: dailyExercisesDoneToday)
        
        success = false
        
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
    }
    
    override func viewDidDisappear(_ animated: Bool){
        conductor.stop()
        
        do {
            try AudioKit.stop()
        } catch {
            AKLog("AudioKit did not stop!")
        }

    }
    
    // send data with segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        NSLog("GTI prepare()")
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
    
    @IBAction func unwindToGTI(_ unwindSegue: UIStoryboardSegue) {}
    
    @IBAction func playInstrumentButtonPressed(_ sender: UIButton) {
        conductor.play()
        
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
            success = true
            segueKeepSameinstrument = false
        }
        updateStats()
        if success {
            NSLog("Correct")
            performSegue(withIdentifier: "segue_gotoSuccessGTI", sender: self)
        } else {
            //goto fail
            segueKeepSameinstrument = true
            NSLog("False")
            performSegue(withIdentifier: "segue_gotoFailGTI", sender: self)
        }
    }
    
    // save stats to our DB
    func updateStats() {
        // 0 is fail, 1 is success
        var activityScore = 0
        if success {
            activityScore = 1
        }
        PDB.insert(table: "memory", actscore: activityScore)
        PDB.dumpAll()
    }
    
    //initializes the audio file to play
    func initPlayer() {
        do {
            try instrument = AKAudioFile(readFileName: correctInstrumentString+".mp3", baseDir: .resources)
            conductor.loadFile(my_file: instrument)
        } catch {
            //error
        }
    }

}

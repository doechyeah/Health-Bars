//
//  GuessThatInstrument.swift
//  Health Bars
//
//  Created by Alvin David on 2019-11-14.
//  Copyright © 2019 Team Rhythm. All rights reserved.
//
import Foundation
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //load for the first time in memory
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        var index = 0
        
        //really bad implementation of unique RNG (I improved it bit - Daniel)
        var set = instrumentNames
        for index in 0...4 {
            randInst = set.randomElement()
//            randInstrumentNumber = Int.random(in: 0...8)//change if we get new instruments
//            if !(randInstruments.contains(instrumentNames[randInstrumentNumber])){
//            randInstruments[index] = instrumentNames[randInstrumentNumber]
            randInstruments[index] = randInst
//            index += 1
            set.remove(randInst)
//            }
        }
        
        //choose instruments out of these 4
        correctInstrumentNumber = Int.random(in: 0...3)
        correctInstrumentString = randInstruments[correctInstrumentNumber]
        
        instrumentImage1.image = UIImage(named: randInstruments[0])
        instrumentImage2.image = UIImage(named: randInstruments[1])
        instrumentImage3.image = UIImage(named: randInstruments[2])
        instrumentImage4.image = UIImage(named: randInstruments[3])
        
        initPlayer()
        AudioKit.output = instrumentPlayer
        initAudioSession()
    }
    
    override func viewDidDisappear(_ animated: Bool){
        //do stuff see long tones by michael
        do{
            try AudioKit.stop()
            try AudioKit.shutdown()
        }
        catch{
            //error
        }
    }
    
    @IBAction func unwindToGTI(_ unwindSegue: UIStoryboardSegue){}
    
    @IBAction func playInstrumentButtonPressed(_ sender: UIButton){
        instrumentPlayer.play(from: 0.0)
        
    }
    
    @IBAction func instrumentButton1Pressed(_ sender: UIButton) {
        if(correctInstrumentString == randInstruments[0]){
            segueKeepSameinstrument = false
            NSLog("Correct")
        }
        else{
            //goto fail
            segueKeepSameinstrument = true
            NSLog("False")
        }
    }
    @IBAction func instrumentButton2Pressed(_ sender: UIButton) {
        if(correctInstrumentString == randInstruments[1]){
            segueKeepSameinstrument = false
            NSLog("Correct")
            //unwind segue (?) to pass
        }
        else{
            //goto fail
            NSLog("False")
            segueKeepSameinstrument = true
        }
    }
    @IBAction func instrumentButton3Pressed(_ sender: UIButton) {
        if(correctInstrumentString == randInstruments[2]){
            segueKeepSameinstrument = false
            NSLog("Correct")
            //unwind segue (?) to pass
        }
        else{
            NSLog("False")
            //goto fail
            segueKeepSameinstrument = true
        }
    }
    @IBAction func instrumentButton4Pressed(_ sender: UIButton) {
        if(correctInstrumentString == randInstruments[3]){
            segueKeepSameinstrument = false
            NSLog("Correct")
            //unwind segue (?) to pass
        }
        else{
            //goto fail
            NSLog("False")
            segueKeepSameinstrument = true
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
            try AKSettings.session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.mixWithOthers)
            try AKSettings.session.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
            try AudioKit.start()
        } catch {
            //error
        }
}

}

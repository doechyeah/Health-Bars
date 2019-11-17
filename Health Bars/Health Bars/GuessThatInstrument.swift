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
    
    //change to pictures instead of text, this is to solely test randomization of the buttons
    @IBOutlet weak var instrumentText1: UILabel!
    @IBOutlet weak var instrumentText2: UILabel!
    @IBOutlet weak var instrumentText3: UILabel!
    @IBOutlet weak var instrumentText4: UILabel!
    
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
        var index = 0
        
        //really bad implementation of unique RNG
        while index < 4{
            randInstrumentNumber = Int.random(in: 0...8)//change if we get new instruments
            if !(randInstruments.contains(instrumentNames[randInstrumentNumber])){
                randInstruments[index] = instrumentNames[randInstrumentNumber]
                index += 1
            }
        }
        
        instrumentText1.text = randInstruments[0]
        instrumentText2.text = randInstruments[1]
        instrumentText3.text = randInstruments[2]
        instrumentText4.text = randInstruments[3]
        
        //choose instruments out of these 4
        correctInstrumentNumber = Int.random(in: 0...3)
        correctInstrumentString = randInstruments[correctInstrumentNumber]
        
        initAudioSession()
        initPlayer()
        
        AudioKit.output = instrumentPlayer
    }
    
    override func viewDidDisappear(_ animated: Bool){
        //do stuff see long tones by michael
    }
    
    @IBAction func unwindToGTI(_ unwindSegue: UIStoryboardSegue){}
    
    @IBAction func playInstrumentButtonPressed(_ sender: UIButton){
        instrumentPlayer.play(from: 0.0)
        listenTimer = Timer.scheduledTimer(timeInterval: playTonePeriod, target: self, selector: #selector(LongTones.doneInstrumentButtonPressed), userInfo: nil, repeats: false) //do we need this lmao
    }
    
    @IBAction func instrumentButton1Pressed(_ sender: UIButton) {
        if(correctInstrumentString == randInstruments[0]){
            segueKeepSameinstrument = false
            //unwind segue (?) to pass
        }
        else{
            //goto fail
            segueKeepSameinstrument = true
        }
    }
    @IBAction func instrumentButton2Pressed(_ sender: UIButton) {
        if(correctInstrumentString == randInstruments[1]){
            segueKeepSameinstrument = false
            //unwind segue (?) to pass
        }
        else{
            //goto fail
            segueKeepSameinstrument = true
        }
    }
    @IBAction func instrumentButton3Pressed(_ sender: UIButton) {
        if(correctInstrumentString == randInstruments[2]){
            segueKeepSameinstrument = false
            //unwind segue (?) to pass
        }
        else{
            //goto fail
            segueKeepSameinstrument = true
        }
    }
    @IBAction func instrumentButton4Pressed(_ sender: UIButton) {
        if(correctInstrumentString == randInstruments[3]){
            segueKeepSameinstrument = false
            //unwind segue (?) to pass
        }
        else{
            //goto fail
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


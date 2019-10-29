//
//  ViewController.swift
//  Health Bars
//
//  Created by Michael Lin on 2019-10-26.
//  Copyright © 2019 Michael Lin. All rights reserved.
//

import AudioKit
import AudioKitUI

import UIKit

class ViewController: UIViewController {
    //@IBOutlet var plot: AKNodeOutputPlot?
    
    let noteFrequencies = [16.35, 17.32, 18.35, 19.45, 20.6, 21.83, 23.12, 24.5, 25.96, 27.5, 29.14, 30.87]
    let noteNamesWithSharps = ["C", "C♯", "D", "D♯", "E", "F", "F♯", "G", "G♯", "A", "A♯", "B"]
    let noteNamesWithFlats = ["C", "D♭", "D", "E♭", "E", "F", "G♭", "G", "A♭", "A", "B♭", "B"]
    
    
    
    var success: Bool = false

    var oscillator1 = AKOscillator()
    //var oscillator2 = AKOscillator()
    //var mixer = AKMixer()
    var mic: AKMicrophone!
    var tracker: AKFrequencyTracker!
    var bandpassfilter: AKBandPassButterworthFilter!
    var silence: AKBooster!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        AKSettings.audioInputEnabled = true
        AKSettings.sampleRate = AudioKit.engine.inputNode.inputFormat(forBus: 0).sampleRate
        mic = AKMicrophone()
        bandpassfilter = AKBandPassButterworthFilter(mic)
        bandpassfilter.centerFrequency = 800
        bandpassfilter.bandwidth = 700
        tracker = AKFrequencyTracker.init(bandpassfilter)
        silence = AKBooster(tracker, gain: 0)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        AudioKit.output = silence
        do {
            try AudioKit.start()
        } catch {
            AKLog("AudioKit did not start!")
        }
        Timer.scheduledTimer(timeInterval: 0.1,
                             target: self,
                             selector: #selector(ViewController.updateUI),
                             userInfo: nil,
                             repeats: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //mixer = AKMixer(oscillator1, oscillator2)

        // Cut the volume in half since we have two oscillators
        //mixer.volume = 0.5
        AudioKit.output = oscillator1
        do {
            try AudioKit.start()
        } catch {
            AKLog("AudioKit did not start!")
        }
    }

    @IBAction func toggleSound(_ sender: UIButton) {
        if oscillator1.isPlaying {
            oscillator1.stop()
            //oscillator2.stop()
            sender.setTitle("Play Sine Waves", for: .normal)
        } else {
            oscillator1.frequency = random(in: 220 ... 880)
            oscillator1.start()
            //oscillator2.frequency = random(in: 220 ... 880)
            //oscillator2.start()
            sender.setTitle("Stop \(Int(oscillator1.frequency))Hz", for: .normal)
        }
    }

    @IBAction func unwindToStart(_ unwindSegue: UIStoryboardSegue) {
        //let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
    }
    
    @IBAction func gotoSecondView(_ sender: UIButton) {
        if success == false {
            performSegue(withIdentifier: "ID_gotoSecondView", sender: self)
        }
    }
    
    @objc func updateUI() {
        if tracker.amplitude > 0.1 {
            frequencyLabel.text = String(format: "%0.1f", tracker.frequency)

            var frequency = Float(tracker.frequency)
            while frequency > Float(noteFrequencies[noteFrequencies.count - 1]) {
                frequency /= 2.0
            }
            while frequency < Float(noteFrequencies[0]) {
                frequency *= 2.0
            }

            var minDistance: Float = 10_000.0
            var index = 0

            for i in 0..<noteFrequencies.count {
                let distance = fabsf(Float(noteFrequencies[i]) - frequency)
                if distance < minDistance {
                    index = i
                    minDistance = distance
                }
            }
            let octave = Int(log2f(Float(tracker.frequency) / frequency))
            noteNameWithSharpsLabel.text = "\(noteNamesWithSharps[index])\(octave)"
            noteNameWithFlatsLabel.text = "\(noteNamesWithFlats[index])\(octave)"
        }
        amplitudeLabel.text = String(format: "%0.2f", tracker.amplitude)
    }
    
}


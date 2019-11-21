//  Health Bars
//
//  Team: Team Rhythm
//
//  AudioKitConductor.swift
//  AudioKit singleton class to manage all AudioKit objects
//  Audiokit does not like dynamic memory management of its objects
//
//  Developers:
//  Michael Lin
//
//  Copyright © 2019 Team Rhythm. All rights reserved.
//
//  Changelog:
//  2019-11-20: Created
//

import AudioKit

class AudioKitConductor {
    static let sharedInstance = AudioKitConductor()
    
    //MARK: Common variables
    var player: AKPlayer!
    var file: AKAudioFile!
    
    //MARK: Long Tones variables
    var mic: AKMicrophone!
    var tracker: AKFrequencyTracker!
    var bandpassFilter: AKBandPassButterworthFilter!
    var silence: AKBooster!
    var mixer: AKMixer!
    
    //MARK: Shake It variables
    // not needed
    
    //MARK: Guess That Instrument variables
    // not needed
    
    init() {
        AKSettings.audioInputEnabled = true
        // workaround for bug in audiokit: https://github.com/AudioKit/AudioKit/issues/1799#issuecomment-506373157
        AKSettings.sampleRate = AudioKit.engine.inputNode.inputFormat(forBus: 0).sampleRate
        
        player = AKPlayer()
        // filter out non-vocal frequencies
        bandpassFilter = AKBandPassButterworthFilter(mic, centerFrequency: 800, bandwidth: 750)
        tracker = AKFrequencyTracker(bandpassFilter)
        // must connect the frequencytracker to an output for functionality.
        silence = AKBooster(tracker, gain: 0)
        mixer = AKMixer(player, silence)
        
        do {
            try AKSettings.session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.mixWithOthers)
            try AKSettings.session.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        } catch {
            NSLog("Could not set output port to speaker")
        }
        
        // set mic input to first (may not be necessary)
        if let inputs = AudioKit.inputDevices {
            do {
                try AudioKit.setInputDevice(inputs[0])
                try mic.setDevice(inputs[0])
            } catch {
                AKLog("Failed to get mic")
            }
        } else {
            AKLog("Failed to get mic")
        }
        
        
        
    }
    
    deinit {
        
    }
    
    internal func resetConnections() {
        
    }
    
    func startLongTones() {
        
        do {
            try AudioKit.start()
        } catch {
            
        }
        
    }
    
}

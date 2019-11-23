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
    // need to dynamically create these, when you swap objects, have to detach down entire signal chain and reconstruct
    var player: AKPlayer!
    var file: AKAudioFile!
    var mixer: AKMixer!
    
    //MARK: Long Tones variables
    // never need to detach these
    var mic: AKMicrophone!
    var bandpassFilter: AKBandPassButterworthFilter!
    var tracker: AKFrequencyTracker!
    var silence: AKBooster!
    
    //MARK: Shake It variables
    // not needed
    
    //MARK: Guess That Instrument variables
    // not needed
    
    init() {
        AKLog("conductor init()")
        
        AKSettings.audioInputEnabled = true
        // workaround for bug in audiokit: https://github.com/AudioKit/AudioKit/issues/1799#issuecomment-506373157
        AKSettings.sampleRate = AudioKit.engine.inputNode.inputFormat(forBus: 0).sampleRate
        
        mic = AKMicrophone()
        // filter out non-vocal frequencies
        bandpassFilter = AKBandPassButterworthFilter(mic, centerFrequency: 800, bandwidth: 750)
        tracker = AKFrequencyTracker(bandpassFilter)
        // must connect the frequencytracker to an output for functionality.
        silence = AKBooster(tracker, gain: 0)
        //mixer = AKMixer(player, silence)
        
        do {
            try AKSettings.session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.mixWithOthers)
            try AKSettings.session.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        } catch {
            AKLog("Could not set output port to speaker")
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
            AKLog("Did not detect any mic on device")
        }
        
        //AudioKit.output = mixer
        //AudioKitStart()
    }
    
    // Reset AKPlayer since it doesn't support swapping files that are different formats
    // have to reconstruct entire signal chain
    internal func resetPlayer() {
        AKLog("resetPlayer()")
        AudioKitStop()
        
        if player != nil { player.stop() }
        if mixer != nil { mixer.stop() }
        
        if player != nil { player.stop() }
        if player != nil { mixer.detach()}
        
        player = nil
        mixer = nil
    }
    
    func loadFile(my_file: AKAudioFile!) {
        AKLog("loadFile()")
        
        file = my_file
        
        if player != nil && file.channelCount == player.audioFile?.processingFormat.channelCount && file.sampleRate == player.audioFile?.processingFormat.sampleRate {
            AKLog("Save resources by not creating new player and output chain")
            // file already in member variable
            loadFileSameFormat()
        } else {
            
            resetPlayer()
            
            player = AKPlayer(audioFile: file)
            mixer = AKMixer(player, silence)
            AudioKit.output = mixer
        }
        
        AudioKitStart()
    }
    
    func loadFileSameFormat() {
        player.load(audioFile: file)
    }
    
    func prerollPlayer(from: Double, to: Double) {
        player.preroll(from: from, to: to)
    }
    
    func play() {
        player.play()
    }
    
    func stop() {
        player.stop()
    }
    
    internal func AudioKitStart() {
        AKLog("AudioKitStart()")
        do {
            try AudioKit.start()
        } catch {
            AKLog("AudioKit did not start correctly")
        }
    }
    
    internal func AudioKitStop() {
        AKLog("AudioKitStop()")
        do {
            try AudioKit.stop()
        } catch {
            AKLog("AudioKit did not stop correctly")
        }
    }
    
}

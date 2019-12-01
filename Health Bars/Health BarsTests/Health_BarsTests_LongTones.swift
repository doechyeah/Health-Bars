//  Health Bars
//
//  Team: Team Rhythm
//
//  Health_BarsTests.swift
//  Unit tests for Health Bars
//
//  Developers:
//  Michael Lin
//
//  Copyright © 2019 Team Rhythm. All rights reserved.
//
//  Changelog:
//  2019-11-01: Created
//

import XCTest
@testable import Health_Bars

class Health_BarsTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFreqConversions() {
        let sut = LongTones()
        
        // 8th octave is absolute limit of human voice, no need to test above that
        for expected_octave in 0...8 {
            // 12 pitches in one octave
            for expected_index in 0...11 {
                let test_freq = Double(1 << expected_octave) * sut.noteFrequencies[expected_index]
                
                let (octave, index) = sut.findPitchFromFrequency(test_freq)
                XCTAssert(octave == expected_octave, "octave:\(octave), expected_octave:\(expected_octave)")
                XCTAssert(index == expected_index, "index:\(index), expected_index:\(expected_index)")
                
                let noteString = sut.findPitchFromFrequencyString(test_freq)
                let expected_noteString = sut.noteNamesWithSharps[expected_index] + "\(expected_octave)"
                XCTAssert(noteString == expected_noteString, "noteString:\(noteString), expected_noteString:\(expected_noteString)")
            }
        }
        
    }
    
    func testFreqConversionsAboveStandardPitches() {
        let sut = LongTones()
        
        // 8th octave is absolute limit of human voice, no need to test above that
        for expected_octave in 0...8 {
            // 12 pitches in one octave
            for expected_index in 0...11 {
                //let test_freq = Double(1 << expected_octave) * sut.noteFrequencies[expected_index] * Double((exp2(1.0/12.0) + 1.0)/2.05)
                let test_freq = Double(1 << expected_octave) * sut.noteFrequencies[expected_index] * Double(exp2(1.0/25.0))
                
                let (octave, index) = sut.findPitchFromFrequency(test_freq)
                XCTAssert(octave == expected_octave, "octave:\(octave), expected_octave:\(expected_octave)")
                XCTAssert(index == expected_index, "index:\(index), expected_index:\(expected_index)")
                
                let noteString = sut.findPitchFromFrequencyString(test_freq)
                let expected_noteString = sut.noteNamesWithSharps[expected_index] + "\(expected_octave)"
                XCTAssert(noteString == expected_noteString, "noteString:\(noteString), expected_noteString:\(expected_noteString)")
            }
        }
        
    }
    
    func testFreqConversionsBelowStandardPitches() {
        let sut = LongTones()
        
        // 8th octave is absolute limit of human voice, no need to test above that
        for expected_octave in 0...8 {
            // 12 pitches in one octave
            for expected_index in 0...11 {
                //let test_freq = Double(1 << expected_octave) * sut.noteFrequencies[expected_index] * Double((exp2(1.0/12.0) + 1.0)/2.05)
                let test_freq = Double(1 << expected_octave) * sut.noteFrequencies[expected_index] * 0.99999 //Double(exp2(-1.0/25.0))
                
                let (octave, index) = sut.findPitchFromFrequency(test_freq)
                XCTAssert(octave == expected_octave, "octave:\(octave), expected_octave:\(expected_octave)")
                XCTAssert(index == expected_index, "index:\(index), expected_index:\(expected_index)")
                
                let noteString = sut.findPitchFromFrequencyString(test_freq)
                let expected_noteString = sut.noteNamesWithSharps[expected_index] + "\(expected_octave)"
                XCTAssert(noteString == expected_noteString, "noteString:\(noteString), expected_noteString:\(expected_noteString)")
            }
        }
        
    }

}

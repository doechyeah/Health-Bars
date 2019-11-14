//
//  Health_BarsTests.swift
//  Health BarsTests
//
//  Created by Michael Lin on 2019-10-29.
//  Copyright © 2019 Team Rhythm. All rights reserved.
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

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        var sut = ShakeIt()
        sut.initPlayer()
        
        sut.initAudioSession()
        
        XCTAssert(sut.songPlayer != nil)
        XCTAssert(sut.songPlayer.isStarted == false)
        
    }

}

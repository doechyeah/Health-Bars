//
//  StatRecord.swift
//  Health Bars
//
//  Created by Daniel Song on 2019-11-16.
//  Copyright © 2019 Team Rhythm. All rights reserved.
//

import Foundation

class StatRecord {
    var currentdate: String
    var yesterday: String
    var score: Int
    var playerID: String
    var attempts: Int
//    var rscore: Int = 0
//    var vscore: Int = 0
//    var mscore: Int = 0
//    var CurrentStreak: Int = 0
//    var CompletedDaily: Bool = false
    
//    let datetime = Expression<String>("datetime")
//    let score = Expression<Int>("score")
//    let attempts = Expression<Int>("attempts")
//    let CurrentStreak = Expression<Int>("CurrentStreak")
//    let CompletedDaily = Expression<Bool>("CompletedDaily")
//    let rscore = Expression<Int>("rhythmscore")
//    let vscore = Expression<Int>("voicescore")	
//    let mscore = Expression<Int>("memoryscore")
//    let pID = Expression<String>("pID")
    var recTable: String
    var recType: Int = 0
    
    convenience init(stattype: String) {
        self.init(stattype: stattype, dateti: Date())
    }
    
    init (stattype: String, dateti: Date) {
        let yesdate = Calendar.current.date(byAdding: .day, value: -1, to: dateti)
        let format = DateFormatter()
        format.dateFormat = "yyyy/MM/dd"
        self.yesterday = format.string(from: yesdate!)
        self.currentdate = format.string(from: dateti)
        self.recTable = stattype
        
        self.score = 0
        self.playerID = "Player1" // Placeholder until we get a useable ID
        self.attempts = 0
//        if stattype == "rhythm"  {
//            self.recType = 1
//        } else if stattype == "memory" {
//            self.recType = 2
//        } else if stattype == "voice" {
//            self.recType = 3
//        }
    }
    
    func updateScore(result: Int) {
        self.score += result
        self.attempts += 1
    }
    
}

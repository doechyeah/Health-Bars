//
//  File.swift
//  Health Bars
//
//  Created by Daniel Song on 2019-11-12.
//  Copyright © 2019 Team Rhythm. All rights reserved.
//

import Foundation
import SQLite

class ProgClass {
    var playerID: String
    var currentdate: String
    let path = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                   .userDomainMask,
                                                   true
    ).first!
    // Initialize tables
    let rhythm = Table("rhythm")
    let voice = Table("voice")
    let memory = Table("memory")
    let DailyStreak = Table("streak")
    let Stats = Table("stats")
    // Initialize entries
    let datetime = Expression<String>("datetime")
    let score = Expression<Int64>("score")
    let attempts = Expression<Int64>("attempts")
    let CurrentStreak = Expression<Int64>("CurrentStreak")
    let CompletedDaily = Expression<Bool>("CompletedDaily")
    let rscore = Expression<Int64>("rscore")
    let vscore = Expression<Int64>("vscore")
    let mscore = Expression<Int64>("mscore")
    let pID = Expression<String>("pID")
    
    init (playID: String) {
        playerID = playID
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyy/MM/dd"
        currentdate = format.string(from: date)
        let db = try! Connection("\(path)/ProgressDB.sqlite3")
        do {
            try db.run(rhythm.create(ifNotExists: true) {
                t in
                t.column(datetime, primaryKey: true)
                t.column(score)
                t.column(attempts)
            })
            try db.run(voice.create(ifNotExists: true) {
                t in
                t.column(datetime, primaryKey: true)
                t.column(score)
                t.column(attempts)
            })
            try db.run(memory.create(ifNotExists: true) {
                t in
                t.column(datetime, primaryKey: true)
                t.column(score)
                t.column(attempts)
            })
            try db.run(DailyStreak.create(ifNotExists: true) {
                t in
                t.column(datetime, primaryKey: true)
                t.column(CurrentStreak)
                t.column(CompletedDaily)
            })
            try db.run(Stats.create(ifNotExists: true) {
                t in
                t.column(datetime, primaryKey: true)
                t.column(pID)
                t.column(rscore)
                t.column(vscore)
                t.column(mscore)
            })
        } catch {
            print("Error Opening Tables")
        }
    }
    
    func insert(table: String, actscore: Int) {
        let db = try! Connection("\(path)/ProgressDB.sqlite3")
        let DBtable = Table(table)
        /*
        switch table {
        case "rhythm":
            DBtable = rhythm
        case "memory":
            DBtable = memory
        case "voice":
            DBtable = voice
        default:
            print("invalid table")
        }
        */
        
        do {
            let dateExist = try db.scalar(DBtable.select(datetime.count))
            if dateExist == 0 {
                do {
                try db.run(DBtable.insert(datetime <- currentdate,
                                          score <- Int64(actscore),
                                          attempts <- 1))
                }
                catch let error {
                    print("Insert failed: \(error)")
                }
            }
            else {
                let daterow = DBtable.filter(datetime == currentdate)
                do {
                try db.run(daterow.update(score += Int64(actscore),
                                          attempts += 1))
                }
                catch  let error {
                    print("Update failed: \(error)")
                }
            }
        } catch let error {
            print("Error with checking date: \(error)")
        }
    }
    
    func genStats() {
        // This function will aggregate the data and update the stat table
    }
    
    func genDaily() {
        // This function will aggregate the data and update the dailystreak table
    }
}


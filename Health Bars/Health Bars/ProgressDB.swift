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
    // MARK: Class variables
    var playerID: String
    var currentdate: String
    var yesterday: String
    let path = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                   .userDomainMask,
                                                   true).first!
    // Initialize tables
    let activities = ["rhythm", "voice", "memory"]
    let rhythm = Table("rhythm")
    let voice = Table("voice")
    let memory = Table("memory")
    let DailyStreak = Table("streak")
    let Stats = Table("stats")
    // Initialize entries
    let datetime = Expression<String>("datetime")
    let score = Expression<Int>("score")
    let attempts = Expression<Int>("attempts")
    let CurrentStreak = Expression<Int>("CurrentStreak")
    let CompletedDaily = Expression<Bool>("CompletedDaily")
    let rhythmscore = Expression<Int>("rhythmscore")
    let voicescore = Expression<Int>("voicescore")
    let memoryscore = Expression<Int>("memoryscore")
    let pID = Expression<String>("pID")
    
    
    init (playID: String) {
        // Initialize the progClass with the players ID
        playerID = playID
        let date = Date()
        let yesdate = Calendar.current.date(byAdding: .day, value: -1, to: date)
        let format = DateFormatter()
        format.dateFormat = "yyyy/MM/dd"
        currentdate = format.string(from: date)
        yesterday = format.string(from: yesdate!)
        // Connect to database file
        let db = try! Connection("\(path)/ProgressDB.sqlite3")
        
        // Try to create tables if they do not exist already
        do {
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
                t.column(rhythmscore)
                t.column(voicescore)
                t.column(memoryscore)
            })
        } catch let error{
            print("Error Opening Tables: \(error)")
        }
        activities.forEach { table in
            let DBtable = Table(table)
            do {
                try db.run(DBtable.create(ifNotExists: true) {
                    t in
                    t.column(datetime, primaryKey: true)
                    t.column(score)
                    t.column(attempts)
                })
//                try db.execute("""
//                    BEGIN TRANSACTION;
//                    CREATE TRIGGER IF NOT EXISTS updateStats\(table)
//                        AFTER UPDATE
//                        ON \(table)
//                    BEGIN
//                        UPDATE stats
//                        SET \(table)score = (SELECT score FROM \(table) WHERE datetime = \(currentdate))
//                        WHERE datetime = \(currentdate);
//                    END;
//                    COMMIT TRANSACTION;
//                    """)
            } catch let error {
                print("Error Creating \(table): \(error)")
            }
        }

        // Create base entries of todays stats if they do not already exist.
        let dateExist = try! db.scalar(DailyStreak.select(datetime.count))
        if dateExist == 0 {
            activities.forEach { table in
                let DBtable = Table(table)
                do {
                    try db.run(DBtable.insert(datetime <- currentdate,
                                              score <- 0,
                                              attempts <- 0))
                } catch let error {
                    print("Insert failed: \(error)")
                }
            }
            do {
                try db.run(DailyStreak.insert(datetime <- currentdate,
                                              CurrentStreak <- 0,
                                              CompletedDaily <- false))
                try db.run(Stats.insert(datetime <- currentdate,
                                        pID <- playID,
                                        rhythmscore <- 0,
                                        voicescore <- 0,
                                        memoryscore <- 0))
            } catch let error {
                print("Insert failed: \(error)")
            }
        }
    }
    
    
    deinit {
        // Destroy the class by updating the daily streaks table
        updateDaily()
//        let db = try! Connection("\(path)/ProgressDB.sqlite3")
//        activities.forEach { tab in
//            try! db.execute("DROP TRIGGER IF EXISTS updateStats\(tab)")
//        }
    }
   
    
    func insert(table: String, actscore: Int) {
        // Insert scores to the desired table
        let db = try! Connection("\(path)/ProgressDB.sqlite3")
        let DBtable = Table(table)
        let daterow = DBtable.filter(datetime == currentdate)
        do {
            try db.run(daterow.update(score += actscore,
                                      attempts += 1))
            let addstatrow = Expression<Int>("\(table)score")
            try db.run(Stats.filter(datetime == currentdate).update(addstatrow += actscore))
        } catch  let error {
            print("Insert failed: \(error)")
        }
    }
    
    func readTable(table: String) -> Dictionary<String, (Int, Int)> {
        // This function will read the entries at the desired table
        let db = try! Connection("\(path)/ProgressDB.sqlite3")
        let DBtable = Table(table)
        var rows: Dictionary<String, (Int, Int)> = [:]
        do {
            for data in try db.prepare(DBtable) {
                rows[data[datetime]] = (data[score],data[attempts])
            }
        } catch let error {
            print("Error reading stat: \(error)")
        }
        return rows
    }
    
    func readStats() -> Dictionary<String, (String, Int, Int, Int)> {
        // This function will aggregate the data and update the stat table
        let db = try! Connection("\(path)/ProgressDB.sqlite3")
        var results: Dictionary<String, (String, Int, Int, Int)> = [:]
        do {
            for data in try db.prepare(Stats) {
                results[data[datetime]] = (data[pID],
                                           data[rhythmscore],
                                           data[voicescore],
                                           data[memoryscore])
            }
        } catch let error {
            print("Error reading Daily streaks: \(error)")
        }
        return results
    }
    
    func readDaily() -> Dictionary<String, ( Int, Bool)> {
        // This function will aggregate the data and update the stat table
        let db = try! Connection("\(path)/ProgressDB.sqlite3")
        var results: Dictionary<String, (Int, Bool)> = [:]
        do {
            for data in try db.prepare(Stats) {
                results[data[datetime]] = (data[CurrentStreak],
                                           data[CompletedDaily])
            }
        } catch let error {
            print("Error reading Daily streaks: \(error)")
        }
        return results
    }
    
    
    func updateDaily() {
        // This function will aggregate the data and update the dailystreak table
        let db = try! Connection("\(path)/ProgressDB.sqlite3")
        var DailyDone: Bool = false
        var skipUpdate: Bool = false
        
        do {
            for x in try db.prepare(DailyStreak.filter(datetime == currentdate)) {
                skipUpdate = x[CompletedDaily]
            }
        } catch let error {
            print("Error performing daily update check: \(error)")
        }
        
        if !skipUpdate {
            activities.forEach { x in
                do {
                    for datarow in try db.prepare(Table(x).filter(datetime == currentdate)) {
                        if datarow[attempts] > 0 {
                            DailyDone = true
                        }
                        else {
                            DailyDone = false
                        }
                    }
                } catch let error {
                    print("The daily streak update failed: \(error)")
                }
            }
            
            if DailyDone {
                let dailyrow = DailyStreak.filter(datetime == currentdate)
                let yestrow = DailyStreak.filter(datetime == yesterday)
                var streak: Int = 0
                do {
                    for yestdata in try db.prepare(yestrow) {
                        if yestdata[CompletedDaily] {
                            streak = yestdata[CurrentStreak]
                        }
                    }
                    try db.run(dailyrow.update(CurrentStreak <- 1+streak,
                                               CompletedDaily <- true))
                } catch  let error {
                    print("Streak Update failed: \(error)")
                }
            }
        }
        // END OF dailyUpdate()
    }
    // END OF progClass
}


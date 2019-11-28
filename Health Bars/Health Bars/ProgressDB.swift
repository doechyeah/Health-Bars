//  Health Bars
//
//  Team: Team Rhythm
//
//  ProgressDB.swift
//  Database that stores all local user data
//
//  Developers:
//  Daniel Song
//
//  Copyright © 2019 Team Rhythm. All rights reserved.
//
//  Changelog:
//  2019-11-10: Created
//
//  Bugs:
//

import Foundation
import SQLite

class ProgClass {
    // MARK: Class variables
    var playerID: String = ""
    var currentdate: String
    var yesterday: String
    let path = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                   .userDomainMask,
                                                   true).first!
    // MARK: Table Variables
    let activities = ["rhythm", "voice", "memory"]
    let rhythm = Table("rhythm")
    let voice = Table("voice")
    let memory = Table("memory")
    let DailyStreak = Table("streak")
    let Stats = Table("stats")
    let PlayData = Table("playdata")
    // MARK: Attribute Variables
    let datetime = Expression<String>("datetime")
    let score = Expression<Int>("score")
    let attempts = Expression<Int>("attempts")
    let CurrentStreak = Expression<Int>("CurrentStreak")
    let CompletedDaily = Expression<Int>("CompletedDaily")
    // Settings: 0 (none), 1 (voice only), 2 (rhythm only), 3 (r+v), 4 (memory only), 5 (v+m), 6 (r+m), 7 (r+m+v)
    let rhythmscore = Expression<Int>("rhythmscore")
    let voicescore = Expression<Int>("voicescore")
    let memoryscore = Expression<Int>("memoryscore")
    let sent = Expression<Bool>("sent")
    let pID = Expression<String>("pID")
    let lastSent = Expression<String>("lastSent")
    
    
    // MARK: Initializer
    init () {
        // Initialize the progClass with the players ID
//        playerID = playID
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
            try db.run(PlayData.create(ifNotExists: true) {
                t in
                t.column(pID)
                t.column(lastSent)
            })
            let count = try db.scalar(PlayData.count)
            if count == 0 {
                let playDict = CreatePlayer()
                //playerID = playDict["_id"] as! String
                playerID = "testid_temp"
                try db.run(PlayData.insert(pID <- playerID,
                                          lastSent <- currentdate
                ))
            } else {
                for x in try db.prepare(PlayData) {
                    playerID = x[pID]
                }
            }
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
                                              CompletedDaily <- 0))
                try db.run(Stats.insert(datetime <- currentdate,
                                        pID <- playerID,
                                        rhythmscore <- 0,
                                        voicescore <- 0,
                                        memoryscore <- 0,
                                        sent <- false))
            } catch let error {
                print("Insert failed: \(error)")
            }
        }
        
    }
    
    // MARK: Destructor
    deinit {
        // Destroy the class by updating the daily streaks table
        updateDaily()
    }
   
    //MARK: Functions
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
    
    func readStats() -> Dictionary<String, (String, Int, Int, Int, Bool)> {
        // This function will aggregate the data and update the stat table
        let db = try! Connection("\(path)/ProgressDB.sqlite3")
        var results: Dictionary<String, (String, Int, Int, Int, Bool)> = [:]
        do {
            for data in try db.prepare(Stats) {
                results[data[datetime]] = (data[pID],
                                           data[rhythmscore],
                                           data[voicescore],
                                           data[memoryscore],
                                           data[sent])
            }
        } catch let error {
            print("Error reading Daily streaks: \(error)")
        }
        return results
    }
    
    func readDaily() -> Dictionary<String, (Int, Int)> {
        // This function will aggregate the data and update the stat table
        let db = try! Connection("\(path)/ProgressDB.sqlite3")
        var results: Dictionary<String, (Int, Int)> = [:]
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
    
    // MARK: Daily stats logic
    func updateDaily() {
        // This function will aggregate the data and update the dailystreak table
        let db = try! Connection("\(path)/ProgressDB.sqlite3")
        var skipUpdate: Bool = false
        
        do {
            for x in try db.prepare(DailyStreak.filter(datetime == currentdate)) {
                if x[CompletedDaily] == 7 {
                    skipUpdate = true
                }
            }
        } catch let error {
            print("Error performing daily update check: \(error)")
        }
        
        if !skipUpdate {
            var dailytruth: Int = 0
            activities.forEach { x in
                do {
                    for datarow in try db.prepare(Table(x).filter(datetime == currentdate)) {
                        if datarow[attempts] > 0 {
                            switch x {
                            case "voice":
                                dailytruth += 1
                            case "rhythm":
                                dailytruth += 2
                            case "memory":
                                dailytruth += 4
                            default:
                                print("ERROR IN UPDATING DAILY")
                            }
                        }
                    }
                } catch let error {
                    print("The daily streak update failed: \(error)")
                }
            }

            let dailyrow = DailyStreak.filter(datetime == currentdate)
            let yestrow = DailyStreak.filter(datetime == yesterday)
            var streak: Int = 0
            do {
                for yestdata in try db.prepare(yestrow) {
                    if yestdata[CompletedDaily] == 7 {
                        streak = yestdata[CurrentStreak]
                    }
                }
                try db.run(dailyrow.update(CurrentStreak <- 1+streak,
                                           CompletedDaily <- dailytruth))
            } catch  let error {
                print("Streak Update failed: \(error)")
            }
        }
        // END OF dailyUpdate()
    }
    
    // MARK: Test Functions
    func InsertTest(dated: String) {
        let db = try! Connection("\(path)/ProgressDB.sqlite3")
        let format = DateFormatter()
        format.dateFormat = "yyyy/MM/dd"
        var current = format.date(from: dated)!
        var next = dated
        while current < format.date(from: currentdate)! {
            let rrand = Int.random(in: 0...10)
            let vrand = Int.random(in: 0...10)
            let mrand = Int.random(in: 0...10)
            let ratte = Int.random(in: rrand...10)
            let vatte = Int.random(in: vrand...10)
            let matte = Int.random(in: mrand...10)
            do {
                activities.forEach { x in
                    var scored = 0
                    var attempted = 0
                    if x == "rhythm" {
                        scored = rrand
                        attempted = ratte
                    } else if x == "voice" {
                        scored = vrand
                        attempted = vatte
                    } else if x == "memory" {
                        scored = mrand
                        attempted = matte
                    }
                    try! db.run(Table(x).insert(datetime <- next,
                                                   score <- scored,
                                                   attempts <- attempted))
                }
                try db.run(Stats.insert(datetime <- next,
                                            pID <- playerID,
                                            voicescore <- vrand,
                                            memoryscore <- mrand,
                                            rhythmscore <- rrand))
            } catch let error {
                print("Insert failed: \(error)")
            }
            current = Calendar.current.date(byAdding: .day, value: +1, to: current)!
            next = format.string(from: current)
        }
    }
    
    func DailyTest(dated: String) {
        let db = try! Connection("\(path)/ProgressDB.sqlite3")
        var dailytruth: Int = 0
        let format = DateFormatter()
        format.dateFormat = "yyyy/MM/dd"
        var current = format.date(from: dated)!
        var streak = 0
        var next = dated
        
        while current <= format.date(from: currentdate)! {
            do {
                for datarow in try db.prepare(Stats.filter(datetime == dated)) {
                    if datarow[voicescore] > 0 {
                        dailytruth += 1
                    } else if datarow[rhythmscore] > 0{
                        dailytruth += 2
                    } else if datarow[memoryscore] > 0 {
                        dailytruth += 4
                    }
                }
                if dailytruth == 7 {
                    streak += 1
                } else {
                    streak = 0
                }
                try db.run(DailyStreak.insert(datetime <- next,
                                              CurrentStreak <- streak,
                                              CompletedDaily <- dailytruth))
            } catch  let error {
                print("Streak Update failed: \(error)")
            }
            current = Calendar.current.date(byAdding: .day, value: +1, to: current)!
            next = format.string(from: current)
        }

    }
}


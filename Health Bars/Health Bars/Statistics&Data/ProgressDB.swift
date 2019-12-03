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
import Alamofire

class ProgClass {
    static let sharedInstance = ProgClass()
    // MARK: Class variables
    let SendURL = "https://advanture.wixsite.com/health-bars-g9/_functions/UpdateStats"
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
    let dailyStreak = Table("streak")
    let Stats = Table("stats")
    let playData = Table("playData")
    // MARK: Attribute Variables
    let datetime = Expression<String>("datetime")
    let score = Expression<Int>("score")
    let attempts = Expression<Int>("attempts")
    let currentStreak = Expression<Int>("currentStreak")
    let completedDaily = Expression<Int>("completedDaily")
    // Settings: 0 (none), 1 (voice only), 2 (rhythm only), 3 (r+v), 4 (memory only), 5 (v+m), 6 (r+m), 7 (r+m+v)
    let rhythmscore = Expression<Int>("rhythmscore")
    let voicescore = Expression<Int>("voicescore")
    let memoryscore = Expression<Int>("memoryscore")
    let rhythmAttempts = Expression<Int>("rhythmAttempts")
    let memoryAttempts = Expression<Int>("memoryAttempts")
    let voiceAttempts = Expression<Int>("voiceAttempts")
    let inst = Expression<Int>("inst")
    
    
    // MARK: Initializer
    init () {
        // Grabs the current date to prep the database insertions.
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
            try db.run(playData.create(ifNotExists: true) {
                t in
                t.column(inst, primaryKey: true)
                t.column(voicescore)
                t.column(memoryscore)
                t.column(rhythmscore)
                t.column(voiceAttempts)
                t.column(memoryAttempts)
                t.column(rhythmAttempts)
            })
            let count = try db.scalar(playData.count)
            if count == 0 {
                try db.run(playData.insert(inst <- 1,
                                           rhythmscore <- 0,
                                           voicescore <- 0,
                                           memoryscore <- 0,
                                           rhythmAttempts <- 0,
                                           voiceAttempts <- 0,
                                           memoryAttempts <- 0))
            }
            try db.run(dailyStreak.create(ifNotExists: true) {
                t in
                t.column(datetime, primaryKey: true)
                t.column(currentStreak)
                t.column(completedDaily)
            })
            try db.run(Stats.create(ifNotExists: true) {
                t in
                t.column(datetime, primaryKey: true)
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
        let streakFilter = dailyStreak.filter(datetime == currentdate)
        let dateExist = try! db.scalar(streakFilter.count)
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
                try db.run(dailyStreak.insert(datetime <- currentdate,
                                              currentStreak <- 0,
                                              completedDaily <- 0))
                try db.run(Stats.insert(datetime <- currentdate,
//                                        pID <- playerID,
                                        rhythmscore <- 0,
                                        voicescore <- 0,
                                        memoryscore <- 0))
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
        let statrow = Stats.filter(datetime == currentdate)
        var daily = 0;
        var dailyBool = false;
        do {
            for x in try db.prepare(daterow) {
                if x[score] == 0 && actscore != 0 {dailyBool = true}
            }
            try db.run(daterow.update(score += actscore,
                                      attempts += 1))
            // Switch decides which attribute to insert the data into and how much to update the daily streak count by.
            switch table {
            case "rhythm":
                daily = 2
                try db.run(statrow.update(rhythmscore += actscore))
                try db.run(playData.filter(inst == 1).update(rhythmscore += actscore,
                                                             rhythmAttempts += 1))
            case "memory":
            daily = 4
            try db.run(statrow.update(memoryscore += actscore))
            try db.run(playData.filter(inst == 1).update(memoryscore += actscore,
                                                         memoryAttempts += 1))
            case "voice":
                daily = 1
                try db.run(statrow.update(voicescore += actscore))
                try db.run(playData.filter(inst == 1).update(voicescore += actscore,
                                                             voiceAttempts += 1))
            
            default:
                print("ERROR ACTIVITY DIDN'T EXIST")
            }
            
            if dailyBool { try db.run(dailyStreak.filter(datetime == currentdate).update(completedDaily += daily))}
        } catch let error {
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
    
    func readPlayer() -> Dictionary<Int, (Int, Int, Int, Int, Int, Int)> {
        // This function is used for the sending the data to the website to update the leaderboard table.
        // Player data is updated accordingly and reset to 0 if it has sent the data.
        let db = try! Connection("\(path)/ProgressDB.sqlite3")
        var sendVoice = 0
        var sendRhythm = 0
        var sendMemory = 0
        var rows: Dictionary<Int, (Int, Int, Int, Int, Int, Int)> = [:]
        do {
            for data in try db.prepare(playData) {
                rows[1] = (data[rhythmscore],
                           data[rhythmAttempts],
                           data[memoryscore],
                           data[memoryAttempts],
                           data[voicescore],
                           data[voiceAttempts])
                sendVoice = data[voiceAttempts]
                sendRhythm = data[rhythmAttempts]
                sendMemory = data[memoryAttempts]
                
            }
            if sendVoice > 0 {
                Alamofire.request(SendURL,
                                  method: .put,
                                  parameters: ["title": "Voice",
                                               "_id":"f28cd49e-b62f-4c12-8bd5-3838bdd067b6",
                                               "voice":rows[1]!.5,
                                               "totalSuccesses":rows[1]!.4],
                                  encoding: JSONEncoding.default)
                    .responseString { response in
                    if response.value == "failed" {
                        print("Oh No")
                    }
                }
                try db.run(playData.filter(inst == 1).update(voicescore <- 0,
                                                             voiceAttempts <- 0))
            }
            if sendRhythm > 0 {
                Alamofire.request(SendURL,
                                  method: .put,
                                  parameters: ["title": "Rhythm",
                                               "_id":"6ac071a8-b084-486c-8e0a-000caf23d1e0",
                                               "voice":rows[1]!.1,
                                               "totalSuccesses":rows[1]!.0],
                                  encoding: JSONEncoding.default)
                    .responseString { response in
                    if response.value == "failed" {
                        print("Oh No")
                    }
                }
                try db.run(playData.filter(inst == 1).update(rhythmscore <- 0,
                                                             rhythmAttempts <- 0))
            }
            if sendMemory > 0 {
                Alamofire.request(SendURL,
                                  method: .put,
                                  parameters: ["title": "Memory",
                                               "_id":"e7e64a06-71ec-44d3-a03e-6a112495d355",
                                               "voice":rows[1]!.3,
                                               "totalSuccesses":rows[1]!.2],
                                  encoding: JSONEncoding.default)
                    .responseString { response in
                    if response.value == "failed" {
                        print("Oh No")
                    }
                }
                try db.run(playData.filter(inst == 1).update(rhythmscore <- 0,
                                                             rhythmAttempts <- 0))
            }
        } catch let error {
            print("Error reading stat: \(error)")
        }
        return rows
    }
    
    func readStats() -> Dictionary<String, (Int, Int, Int)> {
        // This function will aggregate the data and update the stat table
        let db = try! Connection("\(path)/ProgressDB.sqlite3")
        var results: Dictionary<String, (Int, Int, Int)> = [:]
        do {
            for data in try db.prepare(Stats) {
                results[data[datetime]] = (data[rhythmscore],
                                           data[voicescore],
                                           data[memoryscore])
            }
        } catch let error {
            print("Error reading Daily streaks: \(error)")
        }
        return results
    }
    
    
    func readDAct() -> [Bool] {
        // Decoder for the daily activities.
        // ORDER OF RET: MEMORY RHYTHM VOICE
        let db = try! Connection("\(path)/ProgressDB.sqlite3")
        var ret: [Bool] = [false,false,false]
        let daterow = dailyStreak.filter(datetime == currentdate)
        do {
            for data in try db.prepare(daterow) {
                let x = data[completedDaily]
                switch x {
                case 1:
                    ret = [false, false, true]
                case 2:
                    ret = [false, true, false]
                case 3:
                    ret = [false, true, true]
                case 4:
                    ret = [true, false, false]
                case 5:
                    ret = [true, false, true]
                case 6:
                    ret = [true, true, false]
                case 7:
                    ret = [true, true, true]
                default:
                    ret = [false, false, false]
                }
            }
        } catch let error {
            print("Error reading Daily streaks: \(error)")
        }
        return ret
    }
    
    
    func readDaily() -> Dictionary<String, (Int, Int)> {
        // This function will aggregate the data and update the stat table
        let db = try! Connection("\(path)/ProgressDB.sqlite3")
        var results: Dictionary<String, (Int, Int)> = [:]
        do {
            for data in try db.prepare(dailyStreak) {
                results[data[datetime]] = (data[currentStreak],
                                           data[completedDaily])
            }
        } catch let error {
            print("Error reading Daily streaks: \(error)")
        }
        return results
    }
    
    // MARK: Daily stats update streak when the class is deinit or explicityly called (in statistics)
   func updateDaily() {
        // This function will aggregate the data and update the dailyStreak table
        let db = try! Connection("\(path)/ProgressDB.sqlite3")
//        var skipUpdate: Bool = false
        do {
            for x in try db.prepare(dailyStreak.filter(datetime == currentdate)) {
                if x[completedDaily] == 7 {
                    let dailyrow = dailyStreak.filter(datetime == currentdate)
                    let yestrow = dailyStreak.filter(datetime == yesterday)
                    var streak: Int = 0
                    do {
                        for yestdata in try db.prepare(yestrow) {
                            if yestdata[completedDaily] == 7 {
                                streak = yestdata[currentStreak]
                            }
                        }
                        try db.run(dailyrow.update(currentStreak <- 1+streak))
                    } catch  let error {
                        print("Streak Update failed: \(error)")
                    }
//                    skipUpdate = true;
                    
                }
            }
        } catch let error {
            print("Error performing daily update check: \(error)")
        }
    }
    
    // MARK: Test Functions (Uncomment in statistics.swift to enter test data).
    func InsertTest(dated: String) {
        // Creates random data from a specified date and up to (not including) the current date.
        // Only used for debugging.. NON FUNCTIONAL.
        let db = try! Connection("\(path)/ProgressDB.sqlite3")
        let format = DateFormatter()
        format.dateFormat = "yyyy/MM/dd"
        var current = format.date(from: dated)!
        var next = dated
        var streak: Int = 0
        while current < format.date(from: currentdate)! {
            let rrand = Int.random(in: 0...10)
            let vrand = Int.random(in: 0...10)
            let mrand = Int.random(in: 0...10)
            let ratte = Int.random(in: rrand...10)
            let vatte = Int.random(in: vrand...10)
            let matte = Int.random(in: mrand...10)
            var dailytruth: Int = 0
            do {
                activities.forEach { x in
                    var scored = 0
                    var attempted = 0
                    if x == "rhythm" {
                        if rrand > 0 {dailytruth += 2}
                        scored = rrand
                        attempted = ratte
                    } else if x == "voice" {
                        if vrand > 0 {dailytruth += 1}
                        scored = vrand
                        attempted = vatte
                    } else if x == "memory" {
                        if mrand > 0 {dailytruth += 4}
                        scored = mrand
                        attempted = matte
                    }
                    do {
                        try db.run(Table(x).insert(datetime <- next,
                                                       score <- scored,
                                                       attempts <- attempted))
                    } catch let error {
                        print("Insert failed: \(error)")
                    }
                }
                if dailytruth == 7 {
                    streak += 1
                } else {
                    streak = 0
                }
                try db.run(Stats.insert(datetime <- next,
                                        voicescore <- vrand,
                                        memoryscore <- mrand,
                                        rhythmscore <- rrand))
                try db.run(dailyStreak.insert(datetime <- next,
                                              currentStreak <- streak,
                                              completedDaily <- dailytruth))
                try db.run(playData.filter(inst == 1).update(rhythmscore <- rrand,
                                                             voicescore <- vrand,
                                                             memoryscore <- mrand,
                                                             rhythmAttempts <- ratte,
                                                             voiceAttempts <- vatte,
                                                             memoryAttempts <- matte))
            } catch let error {
                print("Insert failed: \(error)")
            }
            current = Calendar.current.date(byAdding: .day, value: +1, to: current)!
            next = format.string(from: current)
        }
    }
    
    // Debugging function to read the values in all the tables.
    func dumpAll() {
        NSLog("readStats()")
        dump(readStats())
        NSLog("readDAct()")
        dump(readDAct())
        NSLog("readDaily()")
        dump(readDaily())
        NSLog("readTable(memory)")
        dump(readTable(table: "memory"))
        NSLog("readTable(rhythm)")
        dump(readTable(table: "rhythm"))
        NSLog("readTable(voice)")
        dump(readTable(table: "voice"))
    }
}

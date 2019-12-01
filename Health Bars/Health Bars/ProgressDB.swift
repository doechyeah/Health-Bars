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
//    var playerID: String = ""
    let SendURL = "https://advanture.wixsite.com/health-bars-g9/_functions-dev/UpdateStats"
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
    let rhythmAttempts = Expression<Int>("rhythmAttempts")
    let memoryAttempts = Expression<Int>("memoryAttempts")
    let voiceAttempts = Expression<Int>("voiceAttempts")
    let inst = Expression<Int>("inst")
    
    
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
                t.column(inst, primaryKey: true)
                t.column(voicescore)
                t.column(memoryscore)
                t.column(rhythmscore)
                t.column(voiceAttempts)
                t.column(memoryAttempts)
                t.column(rhythmAttempts)
            })
            let count = try db.scalar(PlayData.count)
            if count == 0 {
                try db.run(PlayData.insert(inst <- 1,
                                           rhythmscore <- 0,
                                           voicescore <- 0,
                                           memoryscore <- 0,
                                           rhythmAttempts <- 0,
                                           voiceAttempts <- 0,
                                           memoryAttempts <- 0))
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
        var dbool = false;
        do {
            for x in try db.prepare(daterow) {
                if x[score] == 0 && actscore != 0 {dbool = true}
            }
            try db.run(daterow.update(score += actscore,
                                      attempts += 1))
            switch table {
            case "voice":
                daily = 1
                try db.run(statrow.update(voicescore += actscore))
                try db.run(PlayData.filter(inst == 1).update(voicescore += actscore,                                                               voiceAttempts += 1))
            case "rhythm":
                daily = 2
                try db.run(statrow.update(rhythmscore += actscore))
                try db.run(PlayData.filter(inst == 1).update(rhythmscore += actscore,
                                                             rhythmAttempts += 1))
            case "memory":
                daily = 4
                try db.run(statrow.update(memoryscore += actscore))
                try db.run(PlayData.filter(inst == 1).update(memoryscore += actscore,
                                                             memoryAttempts += 1))
            default:
                print("ERROR ACTIVITY DIDN'T EXIST")
            }
            
            if dbool { try db.run(DailyStreak.filter(datetime == currentdate).update(CompletedDaily += daily))}
            
//            readPlayer()
            
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
        // This function will read the entries at the desired table
        let db = try! Connection("\(path)/ProgressDB.sqlite3")
        var rows: Dictionary<Int, (Int, Int, Int, Int, Int, Int)> = [:]
        do {
            for data in try db.prepare(PlayData) {
                rows[1] = (data[rhythmscore],
                           data[rhythmAttempts],
                           data[memoryscore],
                           data[memoryAttempts],
                           data[voicescore],
                           data[voiceAttempts])
            }
            
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
            try db.run(PlayData.filter(inst == 1).update(rhythmscore <- 0,
                                                                 voicescore <- 0,
                                                                 memoryscore <- 0,
                                                                 rhythmAttempts <- 0,
                                                                 voiceAttempts <- 0,
                                                                 memoryAttempts <- 0))
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
        // ORDER OF RET: MEMORY RHYTHM VOICE
        let db = try! Connection("\(path)/ProgressDB.sqlite3")
        var ret: [Bool] = [false,false,false]
        let daterow = DailyStreak.filter(datetime == currentdate)
        do {
            for data in try db.prepare(daterow) {
                let x = data[CompletedDaily]
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
            for data in try db.prepare(DailyStreak) {
                results[data[datetime]] = (data[CurrentStreak],
                                           data[CompletedDaily])
            }
        } catch let error {
            print("Error reading Daily streaks: \(error)")
        }
        return results
    }
    
    // MARK: Daily stats update streak when the class is deinit or explicityly called (in statistics)
   func updateDaily() {
        // This function will aggregate the data and update the dailystreak table
        let db = try! Connection("\(path)/ProgressDB.sqlite3")
//        var skipUpdate: Bool = false
        do {
            for x in try db.prepare(DailyStreak.filter(datetime == currentdate)) {
                if x[CompletedDaily] == 7 {
                    let dailyrow = DailyStreak.filter(datetime == currentdate)
                    let yestrow = DailyStreak.filter(datetime == yesterday)
                    var streak: Int = 0
                    do {
                        for yestdata in try db.prepare(yestrow) {
                            if yestdata[CompletedDaily] == 7 {
                                streak = yestdata[CurrentStreak]
                            }
                        }
                        try db.run(dailyrow.update(CurrentStreak <- 1+streak))
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
    
    // MARK: Test Functions (Uncomment in statistics.swift to enter test data.
    func InsertTest(dated: String) {
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
//                print("RUN ERROR2222")
                try db.run(Stats.insert(datetime <- next,
//                                            pID <- playerID,
                                            voicescore <- vrand,
                                            memoryscore <- mrand,
                                            rhythmscore <- rrand))
                try db.run(DailyStreak.insert(datetime <- next,
                                              CurrentStreak <- streak,
                                              CompletedDaily <- dailytruth))
                try db.run(PlayData.filter(inst == 1).update(rhythmscore <- rrand,
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

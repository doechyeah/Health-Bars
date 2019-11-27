//
//  UploadData.swift
//  Health Bars
//
//  Created by Daniel Song on 2019-11-19.
//  Copyright © 2019 Team Rhythm. All rights reserved.
//

import Foundation
import Alamofire

struct SendData: Codable {
    let playerID: String
    let rscore: Int
    let vscore: Int
    let mscore: Int
}

class UploadClass {
    let PDB = ProgClass()
    var statset: Dictionary<String, (String, Int, Int, Int, Bool)>
    var currentdate: String
    var lastdatesent: String
    var sendAll: Bool = false
    let playerID = "Player1"
    
    // TWO WAYS OF IMPLEMENTING TO ENSURE NO DOUBLE SENDING OF DATA. CREATE A BOOL IN THE STATS TABLE IF SENT OR READ LATEST DATE AND ONLY UPDATE THOSE GREATER TO IT
    let ReadURL = "https://advanture.wixsite.com/health-bars-g9/_functions/DoIExist"
    // final URL will have at end \playerID
    let SendURL = "https://advanture.wixsite.com/health-bars-g9/_functions/uploadMe"
    // final URL will have at end \playerID\date\rscore\vscore\mscore
    
    init() {
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyy/MM/dd"
        currentdate = format.string(from: date)
        statset = PDB.readStats()
        lastdatesent = currentdate
    }
    
    // Template. Need to be tested
    func DoIExist() {
//        let format = DateFormatter()
//        format.dateFormat = "yyyy/MM/dd"
//        let datecurr = format.date(from: currentdate)
        AF.request("\(ReadURL)/\(playerID)").responseString { response in
            // FIND LAST DATE IF IT EXISTS HERE OR SET SENDALL AS TRUE
            if response.value == "NoExist" {
                self.sendAll = true
            }
            else {
                self.lastdatesent = response.value ?? self.currentdate
            }
        }
    }
    
    func uploadMe() {
        var jsonSend = try! JSONSerialization.data(withJSONObject: "", options: [])
        if sendAll {
            jsonSend = try! JSONSerialization.data(withJSONObject: statset, options: [])
        }
        
        AF.request("\(SendURL)/\(jsonSend)").responseString { response in
            if response.value == "failed" {
                print("Oh No")
            }
        }
    }
    
}
func CreatePlayer() -> Dictionary<String,String> {
    let test: Dictionary<String, String> = ["_id": "test"]
    return test
}

////  Health Bars
////
////  Team: Team Rhythm
////
////  Statistics.swift
////
////  Developers:
////  Daniel Song
////
////  Copyright © 2019 Team Rhythm. All rights reserved.
////
////  Changelog:
////
//
//import Foundation
//import Alamofire
//
//struct SendData: Codable {
//    let playerID: String
//    let rscore: Int
//    let vscore: Int
//    let mscore: Int
//}
//
//class UploadClass {
//    let PDB = ProgClass()
//    var statset: Dictionary<String, (Int, Int, Int, Bool)>
//    var currentdate: String
//    var lastdatesent: String
//    var sendAll: Bool = false
//    
//    // TWO WAYS OF IMPLEMENTING TO ENSURE NO DOUBLE SENDING OF DATA. CREATE A BOOL IN THE STATS TABLE IF SENT OR READ LATEST DATE AND ONLY UPDATE THOSE GREATER TO IT
//    let ReadURL = "https://advanture.wixsite.com/health-bars-g9/_functions/DoIExist"
//    // final URL will have at end \playerID
//    let SendURL = "https://advanture.wixsite.com/health-bars-g9/_functions/UploadStats"
//    // final URL will have at end \playerID\date\rscore\vscore\mscore
//    
//    init() {
//        let date = Date()
//        let format = DateFormatter()
//        format.dateFormat = "yyyy/MM/dd"
//        currentdate = format.string(from: date)
//        statset = PDB.readStats()
//        lastdatesent = currentdate
//    }
//    
//    // Template. Need to be tested
////    func DoIExist() {
//////        let format = DateFormatter()
//////        format.dateFormat = "yyyy/MM/dd"
//////        let datecurr = format.date(from: currentdate)
////        Alamofire.request("\(ReadURL)/\(playerID)").responseString { response in
////            // FIND LAST DATE IF IT EXISTS HERE OR SET SENDALL AS TRUE
////            if response.value == "NoExist" {
////                self.sendAll = true
////            }
////            else {
////                self.lastdatesent = response.value ?? self.currentdate
////            }
////        }
////    }
//    // FOR AJ: THIS IS A TEMPLATE BUT MAY NOT BE CORRECT. CHECK OUT https://www.raywenderlich.com/35-alamofire-tutorial-getting-started for put requests.
//    func UploadStats() {
////        var sendData: Dictionary<String, Any> = [:]
//        var r_Success: Int
//        var m_Success: Int
//        var v_Success: Int
//        var r_Attempts: Int
//        var m_Attempts: Int
//        var v_Attempts: Int
//        for x in statset {
//            if (x.1.3) {
//                r_Success += x.1.1
//                m_Success += x.1.2
//                v_Success += x.1.3
//            }
//            
//        }
//        Alamofire.request(SendURL, method: .put, parameters: param, endcoding: JSONEncoding.default).responseString { response in
//            if response.value == "failed" {
//                print("Oh No")
//            }
//        }
//    }
//    
//}
//func CreatePlayer() -> Dictionary<String,Any> {
//    let param: Dictionary<String, Any> = ["title":"newplayer1","memory":0,"voice":0,"rhythm":0]
//    var test: Dictionary<String, Any> = [:]
//    
//    Alamofire.request("https://advanture.wixsite.com/health-bars-g9/_functions-dev/CreatePlayer", method: .post,  parameters: param, encoding: JSONEncoding.default)
//        .responseJSON { response in
//            NSLog(response.debugDescription)
//            switch response.result {
//            case .success(let value):
//                test = value as! Dictionary<String, Any>
//                print("Create TEST DEBUG")
//                dump(test)
//            case .failure(let error):
//                print(error)
//            }
//    }
//    
//    return test
//}

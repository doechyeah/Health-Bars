//  Health Bars
//
//  Team: Team Rhythm
//
//  Statistics.swift
//
//  Developers:
//  Daniel Song
//  Trevor Chow
//
//  Copyright © 2019 Team Rhythm. All rights reserved.
//
//  Changelog:
//

import Foundation

import UIKit
import Charts

class grabTest {
    var dailydata: Dictionary<String, (Int, Int)>
    var statsdata: Dictionary<String, (String, Int, Int, Int, Bool)>
    var rdata: Dictionary<String, (Int, Int)>
    var mdata: Dictionary<String, (Int, Int)>
    var vdata: Dictionary<String, (Int, Int)>
    var dailyComplete: Int!
    var date: String!
    var yesterday: String!
    var copy_date: String!
    var v_score: Int!
    var m_score: Int!
    var r_score: Int!
    var v_total_attempts: Int!
    var r_total_attempts: Int!
    var m_total_attempts: Int!
    var v_attempt_array: [Int] = []
    var r_attempt_array: [Int] = []
    var m_attempt_array: [Int] = []
    
    init() {
        let PDB = ProgClass()
        let current_date = Date()
        //let yesdate = Calendar.current.date(byAdding: .day, value: -1, to: current_date)
        let format = DateFormatter()
        format.dateFormat = "yyyy/MM/dd"
        date = format.string(from: current_date)
        //yesterday = format.string(from: yesdate!)
        PDB.InsertTest(dated: date)
        PDB.DailyTest(dated: date)
        dailydata = PDB.readDaily()
        statsdata = PDB.readStats()
        rdata = PDB.readTable(table: "rhythm")
        mdata = PDB.readTable(table: "memory")
        vdata = PDB.readTable(table: "voice")
        dailyComplete = dailydata[date]!.1
        //r_score = statsdata[date]!.1
        //v_score = statsdata[date]!.2
        //m_score = statsdata[date]!.3
    
        copy_date = date
        // probably able to optimize this better, but this will do for now
        for index in 0...3
        {
            if index == 1
            {
                let yesdate = Calendar.current.date(byAdding: .day, value: -1, to: current_date)
                let format = DateFormatter()
                format.dateFormat = "yyyy/MM/dd"
                date = format.string(from: current_date)
                yesterday = format.string(from: yesdate!)
                copy_date = yesterday
                
            }
            else if index == 2
            {
                let yesdate = Calendar.current.date(byAdding: .day, value: -2, to: current_date)
                let format = DateFormatter()
                format.dateFormat = "yyyy/MM/dd"
                date = format.string(from: current_date)
                yesterday = format.string(from: yesdate!)
                copy_date = yesterday
                           
            }
            else if index == 3
            {
                let yesdate = Calendar.current.date(byAdding: .day, value: -3, to: current_date)
                let format = DateFormatter()
                format.dateFormat = "yyyy/MM/dd"
                date = format.string(from: current_date)
                yesterday = format.string(from: yesdate!)
                copy_date = yesterday
            }
            v_attempt_array[index] = vdata[copy_date]!.1
            r_attempt_array[index] = rdata[copy_date]!.1
            m_attempt_array[index] = mdata[copy_date]!.1
            
        }
        
    }
}

class Statistics: UIViewController, ProgressBarProtocol {
    //badges pic
    @IBOutlet weak var mic: UIImageView!
    @IBOutlet weak var equalizer: UIImageView!
    @IBOutlet weak var memory: UIImageView!
    
    var score:Int!
    
    //@IBOutlet weak var barChartView: BarChartView!
    
    let AggData = grabTest()
    
    func unwindSegueFromView() {
        NSLog("Statistics delegate unwind function")
        performSegue(withIdentifier: "segue_unwindtoNavigationMenu", sender: self)
    }
    
    @IBOutlet weak var progressBar: ProgressBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       // EXTRA RANDOM DATA TO INPUT INTO THE GAME FOR DISPLAY

       //load for the first time in memory
       //barChartView.noDataText = "You need to provide data for the chart."
        
        progressBar.delegate = self
        progressBar.setVars(new_titleText: "STATISTICS")
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        //For the 3 badges at the top of the screen
        if AggData.dailyComplete == 0
        {
            //no exercises complete, all badges grey
        }
        else if AggData.dailyComplete == 1
        {
            //make voice badge green, others black
        }
        else if AggData.dailyComplete == 2
        {
            //make rhythm badge green, others black
        }
        else if AggData.dailyComplete == 3
        {
            //make voice and rhythm badge green, other black
        }
        else if AggData.dailyComplete == 4
        {
            //make memory badge green, others black
        }
        else if AggData.dailyComplete == 5
        {
            //make voice and memory badge green, other black
        }
        else if AggData.dailyComplete == 6
        {
            //make rhythm and memory badge green, other black
        }
        else if AggData.dailyComplete == 7
        {
            //make all badges green
        }
        
        //for bar graph that displays number of games played for each day:
        //values are stored in these arrays for each activity
        //0 = current day, 1 = previous day, 2 = 2 days before, 3 = 3 days before
        //AggData.v_attempt_array[0]
        //AggData.r_attempt_array[0]
        //AggData.m_attempt_array[0]
        
        /*for bar graph that displays success rate:
        - read from database total attempts and passed for each category
        - display the percentage of success
        - success % == total_passed/total_attempts*/
        
        //still in progress
        
    }
}

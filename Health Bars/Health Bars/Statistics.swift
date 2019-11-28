//  Health Bars
//
//  Team: Team Rhythm
//
//  Statistics.swift
//
//  Developers:
//  Daniel Song
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
    
    init() {
        let PDB = ProgClass()
         let date = "2019/11/01"
         PDB.InsertTest(dated: date)
         PDB.DailyTest(dated: date)
         dailydata = PDB.readDaily()
         statsdata = PDB.readStats()
         rdata = PDB.readTable(table: "rhythm")
         mdata = PDB.readTable(table: "memory")
         vdata = PDB.readTable(table: "voice")
    }
}

class Statistics: UIViewController, ProgressBarProtocol {
    @IBOutlet weak var barChartView: BarChartView!
    
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
       barChartView.noDataText = "You need to provide data for the chart."
        
        progressBar.delegate = self
        progressBar.setVars(new_titleText: "STATISTICS")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}

//  Health Bars
//
//  Team: Team Rhythm
//
//  Statistics.swift
//
//  Developers:
//  Daniel Song
//  Trevor Chow
//  Martin Zhilin Lu
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
    var statsdata: Dictionary<String, (Int, Int, Int)>
//    var rdata: Dictionary<String, (Int, Int)>
//    var mdata: Dictionary<String, (Int, Int)>
//    var vdata: Dictionary<String, (Int, Int)>
    var dailyComplete: [Bool]
    var date: String!
    var yesterday: String!
    var copy_date: String!
    var voiceSuccessData: Dictionary<Int,Int> = [:]
    var rhythmSuccessData: Dictionary<Int,Int> = [:]
    var mmemorySuccessData: Dictionary<Int,Int> = [:]
    var streaktoday: Int
    
    init() {
        let PDB = ProgClass.sharedInstance
//        let test_date = "2019/11/26"
        //let yesdate = Calendar.current.date(byAdding: .day, value: -1, to: current_date)
        let date = Date()
        let twodate = Calendar.current.date(byAdding: .day, value: -1, to: date)
        let threedate = Calendar.current.date(byAdding: .day, value: -2, to: date)
        let fourdate = Calendar.current.date(byAdding: .day, value: -3, to: date)
        let format = DateFormatter()
        format.dateFormat = "yyyy/MM/dd"
        let currentdate = format.string(from: date)
        let twoday = format.string(from: twodate!)
        let threeday = format.string(from: threedate!)
        let fourday = format.string(from: fourdate!)
        let dateArray = [currentdate, twoday, threeday, fourday]
        // MARK: TEST FUNCTION UNCOMMENT TO ENTER FAKE DATA
//        PDB.InsertTest(dated: test_date)
        PDB.updateDaily()
        dailydata = PDB.readDaily()
        streaktoday = dailydata[currentdate]!.0
        statsdata = PDB.readStats()
//        rdata = PDB.readTable(table: "rhythm")
//        mdata = PDB.readTable(table: "memory")
//        vdata = PDB.readTable(table: "voice")
        dailyComplete = PDB.readDAct()
        _ = PDB.readPlayer()

        var i = 3
        dateArray.forEach { x in
            if statsdata[x] != nil {
                voiceSuccessData[i] = statsdata[x]!.1
                mmemorySuccessData[i] = statsdata[x]!.2
                rhythmSuccessData[i] = statsdata[x]!.0
            } else {
                voiceSuccessData[i] = 0
                mmemorySuccessData[i] = 0
                rhythmSuccessData[i] = 0
            }
 
            i -= 1
        }
        
        
        
        // probably able to optimize this better, but this will do for now
        
        
    }
}

class Statistics: UIViewController, ProgressBarProtocol {
    //badges pic
    @IBOutlet weak var mic: UIImageView!
    @IBOutlet weak var equalizer: UIImageView!
    @IBOutlet weak var memory: UIImageView!
    
    @IBOutlet weak var current_label: UILabel!
    
    @IBOutlet weak var barChartView: BarChartView!
    
    let myData = grabTest()
    
    var score:Int!
    
    
    func barChartUpdate (){
        var entry1: [BarChartDataEntry] = []
        var entry2: [BarChartDataEntry] = []
        var entry3: [BarChartDataEntry] = []
        
        for i in 0...3{
            entry1.append(BarChartDataEntry(x: Double(i), y: Double(myData.voiceSuccessData[i]!)))
            entry2.append(BarChartDataEntry(x: Double(i), y: Double(myData.rhythmSuccessData[i]!)))
            entry3.append(BarChartDataEntry(x: Double(i), y: Double(myData.mmemorySuccessData[i]!)))
        }
//        let entry1 = BarChartDataEntry(x: 1.0, y: Double(number1.value))
//        let entry2 = BarChartDataEntry(x: 2.0, y: Double(number2.value))
//        let entry3 = BarChartDataEntry(x: 3.0, y: Double(number3.value))
        let chartDataSet1 = BarChartDataSet(entries: entry1, label: "voice success")
        let chartDataSet2 = BarChartDataSet(entries: entry2, label: "rhythm success")
        let chartDataSet3 = BarChartDataSet(entries: entry3, label: "memory success")
        
        let dataSets: [BarChartDataSet] = [chartDataSet1,chartDataSet2,chartDataSet3]
        chartDataSet1.colors = [UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1)]
        chartDataSet2.colors = [UIColor(red: 0/255, green: 255/255, blue: 0/255, alpha: 1)]
        chartDataSet3.colors = [UIColor(red: 0/255, green: 0/255, blue: 255/255, alpha: 1)]
        
        let chartData = BarChartData(dataSets: dataSets)
        
        let groupSpace = 0.28
        let barSpace = 0.04
        let barWidth = 0.2
        
        let NumofGroup = 4
        chartData.barWidth = barWidth;
        barChartView.xAxis.axisMinimum = 0
        let gg = chartData.groupWidth(groupSpace: groupSpace, barSpace: barSpace)
        print("Groupspace: \(gg)")
        barChartView.xAxis.axisMaximum = 0 + gg * Double(NumofGroup)

        chartData.groupBars(fromX: 0, groupSpace: groupSpace, barSpace: barSpace)
        //chartData.groupWidth(groupSpace: groupSpace, barSpace: barSpace)
        barChartView.notifyDataSetChanged()

        barChartView.data = chartData

        //background color
        barChartView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)

        //chart animation
        barChartView.animate(xAxisDuration: 1.5, yAxisDuration: 1.5, easingOption: .linear)

        //barChart.chartDescription?.text = "Number of Widgets by Type"

        //All other additions to this function will go here

        //This must stay at end of function
        barChartView.notifyDataSetChanged()
    }
    
    let AggData = grabTest()
    
    func unwindSegueFromView() {
        NSLog("Statistics delegate unwind function")
        performSegue(withIdentifier: "segue_unwindtoNavigationMenu", sender: self)
    }
    
    @IBOutlet weak var progressBar: ProgressBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       // EXTRA RANDOM DATA TO INPUT INTO THE GAME FOR DISPLAY
        current_label.text = "Daily Streak: "+String(AggData.streaktoday)
        
        //For group bar
       //load for the first time in memory
        barChartView.noDataText = "You need to provide data for the chart."
        
        let legend = barChartView.legend
        legend.enabled = true
        legend.horizontalAlignment = .center
         legend.verticalAlignment = .top
         legend.orientation = .vertical
         legend.drawInside = false
         legend.yOffset = 10.0;
         legend.xOffset = 10.0;
         legend.yEntrySpace = 0.0;

        weak var axisFormatDelegate: IAxisValueFormatter?
         let xaxis = barChartView.xAxis
         xaxis.valueFormatter = axisFormatDelegate
         xaxis.drawGridLinesEnabled = true
         xaxis.labelPosition = .bottom
         xaxis.centerAxisLabelsEnabled = true
         xaxis.valueFormatter = IndexAxisValueFormatter(values:["Three days ago","Two days ago","Yesterday", "Today"])
         xaxis.granularity = 1


         let leftAxisFormatter = NumberFormatter()
         leftAxisFormatter.maximumFractionDigits = 1

         let yaxis = barChartView.leftAxis
         yaxis.spaceTop = 0.35
         yaxis.axisMinimum = 0
         yaxis.drawGridLinesEnabled = false

         barChartView.rightAxis.enabled = false
        //axisFormatDelegate = self

         barChartUpdate()
        
        
        
        progressBar.delegate = self
        progressBar.setVars(new_titleText: "STATISTICS")
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
            //make all badges green
        mic.isHighlighted = AggData.dailyComplete[2]
        equalizer.isHighlighted = AggData.dailyComplete[1]
        memory.isHighlighted = AggData.dailyComplete[0]

        
        //for bar graph that displays number of games played for each day:
        //values are stored in these arrays for each activity
        //0 = current day, 1 = previous day, 2 = 2 days before, 3 = 3 days before
        //AggData.voiceSuccessData[0]
        //AggData.rhythmSuccessData[0]
        //AggData.mmemorySuccessData[0]
        
        
        /*for bar graph that displays success rate:
        - read from database total attempts and passed for each category
        - display the percentage of success
        - success % == total_passed/total_attempts*/
        
        //still in progress
        
    }
}

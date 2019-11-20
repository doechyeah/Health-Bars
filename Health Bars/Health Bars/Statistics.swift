//
//  Statistics.swift
//  Health Bars
//
//  Created by Daniel Song on 2019-11-19.
//  Copyright © 2019 Team Rhythm. All rights reserved.
//

import Foundation

import UIKit
import Charts

class Statistics: UIViewController {
    @IBOutlet weak var barChartView: BarChartView!


    override func viewDidLoad() {
        super.viewDidLoad()
        //load for the first time in memory
        barChartView.noDataText = "You need to provide data for the chart."
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
}

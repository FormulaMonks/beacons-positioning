//
//  CBLogChartViewController.swift
//  BeaconsHeatmap
//
//  Created by Luis Floreani on 6/15/15.
//  Copyright (c) 2015 Citrusbyte LLC. All rights reserved.
//

import Foundation
import UIKit
import Charts

class CBLogChartViewController : UIViewController {
    var logs: NSArray?
    @IBOutlet var chartView: LineChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let values = logs {
            var xVals = [String]()
            var yVals = [ChartDataEntry]()
            
            var i = 0

            for val in values {
                let dict = val as! NSDictionary
                let distance = dict["distance"] as! Double
                let minor = dict["minor"] as! Int
                let time = String(format:"%f", distance)
                if minor == 6130 {
                    xVals.append(time)
                    yVals.append(ChartDataEntry(value: distance, xIndex: i++))
                }
            }
            
            let dataSet = LineChartDataSet(yVals: yVals, label: "Distance measure")
            let data = LineChartData(xVals: xVals, dataSet: dataSet)
            chartView.data = data
        }
    }
}

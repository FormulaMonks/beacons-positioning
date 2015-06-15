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

class AxisData {
    var xVals = [String]()
    var yVals = [ChartDataEntry]()
}

class CBLogChartViewController : UIViewController {
    var logs: NSArray?
    @IBOutlet var chartView: LineChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadChartData()
    }
    
    func loadChartData() {
        let colors = [UIColor.redColor(), UIColor.greenColor(), UIColor.blueColor(), UIColor.blackColor(), UIColor.grayColor(), UIColor.cyanColor(), UIColor.brownColor(), UIColor.yellowColor()]
        
        if let values = logs {
            var i = 0
            var dataByMinor = [Int : AxisData]()
            for val in values {
                let dict = val as! NSDictionary
                let distance = dict["distance"] as! Double
                let minor = dict["minor"] as! Int
                let time = String(format:"%f", distance)
                
                var axisData = dataByMinor[minor];
                if axisData == nil {
                    axisData = AxisData()
                    dataByMinor[minor] = axisData
                }
                
                axisData?.xVals.append(time)
                axisData?.yVals.append(ChartDataEntry(value: distance, xIndex: i++))
            }
            
            var dataSets = [LineChartDataSet]()
            var xVals = [String]()
            i = 0
            for (key, value) in dataByMinor {
                let dataSet = LineChartDataSet(yVals: value.yVals, label: String(format:"%d", key))
                dataSets.append(dataSet)
                if (xVals.count < value.xVals.count) {
                    xVals = value.xVals;
                }
                dataSet.setColor(colors[i % colors.count])
                dataSet.setCircleColor(colors[i % colors.count])
                i++
            }
            
            let data = LineChartData(xVals: xVals, dataSets: dataSets)
            chartView.data = data
        }
    }
}

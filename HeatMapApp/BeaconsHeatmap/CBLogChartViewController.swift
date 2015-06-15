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
        
        chartView.descriptionText = ""
        chartView.drawGridBackgroundEnabled = false

        let xAxis = chartView.xAxis;
        xAxis.drawGridLinesEnabled = false
        let yAxis = chartView.leftAxis;
        yAxis.valueFormatter = NSNumberFormatter()
        yAxis.valueFormatter?.maximumFractionDigits = 1
        yAxis.valueFormatter?.positiveSuffix = " m"
        let yAxisRight = chartView.rightAxis;
        yAxisRight.valueFormatter = yAxis.valueFormatter

        loadChartData()
    }
    
    func groupIntoAxisDataByMinor(var logs: NSArray) -> [Int : AxisData] {
        var dataByMinor = [Int : AxisData]()
        var i = 0
        for val in logs {
            let dict = val as! NSDictionary
            let distance = dict["distance"] as! Double
            let time = dict["time"] as! Double
            let minor = dict["minor"] as! Int
            let timeString = String(format:"%d sec", Int(time))
            
            var axisData = dataByMinor[minor];
            if axisData == nil {
                axisData = AxisData()
                dataByMinor[minor] = axisData
            }
            
            axisData?.xVals.append(timeString)
            axisData?.yVals.append(ChartDataEntry(value: distance, xIndex: i++))
        }
        
        return dataByMinor
    }
    
    func loadChartData() {
        let colors = [UIColor(rgba: "#603613"), UIColor(rgba: "#eac690"), UIColor(rgba: "#c70000"), UIColor(rgba: "#868686"), UIColor(rgba: "#363469")]
        
        if let values = logs {
            var dataByMinor = groupIntoAxisDataByMinor(values)
            
            var dataSets = [LineChartDataSet]()
            var xVals = [String]()
            var i = 0
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

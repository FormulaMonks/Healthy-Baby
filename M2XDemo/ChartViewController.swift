//
//  ChartViewController.swift
//  M2XDemo
//
//  Created by Luis Floreani on 11/13/14.
//  Copyright (c) 2014 citrusbyte.com. All rights reserved.
//

import Foundation

class ChartDetailValue {
    let label: String
    let value: String
    
    init(label: String, value: String) {
        self.label = label
        self.value = value
    }
}

@objc protocol ChartViewControllerDelegate : class {
    func values() -> [ChartDetailValue]
    optional func formatDate(timestamp: String) -> String
    optional func formatValue(value: Double) -> String
}

class ChartViewController : HBBaseViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var graphView: BEMSimpleLineGraphView!
    @IBOutlet var sliderView: NMRangeSlider!
    @IBOutlet var deviceIdLabel: UILabel!
    @IBOutlet var sliderLowerLabel: UILabel!
    @IBOutlet var sliderHigherLabel: UILabel!
    @IBOutlet var cacheLabel: UILabel!
    @IBOutlet var separatorView: UIView!
    @IBOutlet var barView: UIView!
    @IBOutlet var tableView: UITableView!
    
    weak var delegate: ChartViewControllerDelegate?
    
    var axisXUnit: String?
    var axisYUnit: String?
    var minValue: Int = 0
    var maxValue: Int = 0

    var values: [AnyObject]?
    var details = [ChartDetailValue]()

    var selectedValue = "-"
    
    let maxSamples = 1000 // for interpolation purposes
    
    var color: UIColor {
        set {
            graphView.colorTop = newValue
            graphView.colorBottom = newValue
            sliderView.tintColor = newValue
            separatorView.backgroundColor = newValue
            
            barView.backgroundColor = newValue.colorWithAlphaComponent(0.5)
        }
        get {
            return graphView.colorTop
        }
    }
    
    var cached: Bool {
        set {
            cacheLabel.alpha = newValue ? 1.0 : 0.0
        }
        get {
            return cacheLabel.alpha != 0
        }
    }
    
    var showPoints: Bool {
        set {
            graphView.alwaysDisplayDots = newValue
        }
        get {
            return graphView.alwaysDisplayDots
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sliderView.stepValueContinuously = true
        sliderView.continuous = false
        sliderView.stepValue = 1
        sliderView.alpha = 0
        sliderView.backgroundColor = UIColor.clearColor()
        sliderLowerLabel.text = "-"
        sliderHigherLabel.text = "-"
        
        sliderLowerLabel.alpha = 0
        sliderHigherLabel.alpha = 0
        cacheLabel.alpha = 0

        barView.backgroundColor = UIColor.clearColor()
        separatorView.backgroundColor = UIColor.clearColor()
        graphView.backgroundColor = UIColor.clearColor()
        graphView.enableBezierCurve = true
        graphView.enableTouchReport = true
        graphView.enablePopUpReport = true
        graphView.enableYAxisLabel = true
        graphView.enableXAxisLabel = true
        graphView.enableReferenceYAxisLines = true
        graphView.colorXaxisLabel = UIColor.whiteColor()
        graphView.colorYaxisLabel = UIColor.whiteColor()
    }
    
    // MARK: Slider
    
    func updateOnNewValues() {
        minValue = 0
        maxValue = values != nil ? values!.count - 1 : 0
        
        sliderLowerLabel.alpha = maxValue > 0 ? 1 : 0
        sliderHigherLabel.alpha = maxValue > 0 ? 1 : 0
        sliderView.alpha = maxValue > 0 ? 1 : 0
        
        if maxValue > 0 {
            sliderView.minimumValue = 0
            sliderView.lowerValue = sliderView.minimumValue
            sliderView.maximumValue = Float(maxValue)
            sliderView.upperValue = sliderView.maximumValue
        }
        
        updateSliderLabels()
        
        graphView.reloadGraph()

        updateDetails()
    }
    
    @IBAction func sliderDidChange(slider: NMRangeSlider) {
        minValue = Int(slider.lowerValue)
        maxValue = Int(slider.upperValue)
        
        updateSliderLabels()

        var timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: graphView, selector: Selector("reloadGraph"), userInfo: nil, repeats: false)
    }
    
    private func updateSliderLabels() {
        if realNumberOfPointsInLineGraph() > 0 {
            let minIndex = realIndexForIndex(0)
            let maxIndex = realIndexForIndex(numberOfPointsInLineGraph(graphView) - 1)
            sliderLowerLabel.text = "\(fullDateLabelForIndex(minIndex))"
            sliderHigherLabel.text = "\(fullDateLabelForIndex(maxIndex))"
            
            updateDetails()
        }
    }
    
    func minMaxValues() -> (Double, Double) {
        let minIndex = realIndexForIndex(0)
        let maxIndex = realIndexForIndex(numberOfPointsInLineGraph(graphView) - 1)

        return (valueForIndex(minIndex)!, valueForIndex(maxIndex)!)
    }
    
    // MARK: Graph
    
    private func realNumberOfPointsInLineGraph() -> NSInteger {
        return maxValue - minValue + 1
    }
    
    func numberOfPointsInLineGraph(graph: BEMSimpleLineGraphView) -> NSInteger {
        return min(maxSamples, realNumberOfPointsInLineGraph())
//        return realNumberOfPointsInLineGraph()
    }
    
    func numberOfGapsBetweenLabelsOnLineGraph(graph: BEMSimpleLineGraphView) -> NSInteger {
        return numberOfPointsInLineGraph(graphView) / 5
    }
    
    private func realIndexForIndex(index: NSInteger) -> NSInteger {
        let gap : Float = max(1.0, Float(realNumberOfPointsInLineGraph() - 1) / Float(maxSamples - 1))
        let jump = Int(round(Float(index) * gap))
        return values!.count - 1 - minValue - jump
//        return values!.count - 1 - minValue - index
    }
    
    func lineGraph(graph: BEMSimpleLineGraphView, valueForPointAtIndex index: NSInteger) -> CGFloat {
        let realIndex = realIndexForIndex(index)
        let value = values?[realIndex] as [String: AnyObject]
        let val = value["value"] as Double
        let fl = Float(val)
        let ret = CGFloat(fl)
        return ret
    }
    
    private func dateLabelForIndex(index: NSInteger) -> String {
        let value = values?[index] as [String: AnyObject]
        let timestamp = value["timestamp"] as String
        
        let date = NSDate.fromISO8601(timestamp, timeZone: NSTimeZone.systemTimeZone(), locale: NSLocale.currentLocale())
        
        return date.formattedDateWithFormat("LLL dd")
    }

    private func fullDateLabelForIndex(index: NSInteger) -> String {
        let value = values?[index] as [String: AnyObject]
        let timestamp = value["timestamp"] as String
        
        if delegate?.formatDate != nil {
            return delegate!.formatDate!(timestamp)
        } else {
            let date = NSDate.fromISO8601(timestamp, timeZone: NSTimeZone.systemTimeZone(), locale: NSLocale.currentLocale())
            
            let formatted = date.formattedDateWithFormat("LLL dd YYYY")
            
            return formatted
        }
    }
    
    private func fullValueForIndex(index: NSInteger) -> String {
        let val = valueForIndex(index)
        
        if delegate?.formatValue != nil {
            return delegate!.formatValue!(val!)
        } else {
            return "\(val!)"
        }
    }

    func valueForIndex(index: NSInteger) -> Double? {
        let value = values?[index] as [String: AnyObject]
        var doubleValue = value["value"] as Double
        return Double(Int(doubleValue * 100))/100.0
    }
    
    func lineGraph(graph: BEMSimpleLineGraphView, labelOnXAxisForIndex index: NSInteger) -> NSString {
        let realIndex = realIndexForIndex(index)
        
        return dateLabelForIndex(realIndex)
    }
    
    func popupSuffixForlineGraph(graph: BEMSimpleLineGraphView) -> NSString {
        return " \(axisYUnit!)"
    }

    func minValueForLineGraph(graph: BEMSimpleLineGraphView) -> CGFloat {
        var min: CGFloat = CGFloat(INT16_MAX)
        
        for value in values! {
            var val = value["value"] as CGFloat
            if val < min {
                min = val
            }
        }
        
        return min / 1.15 // arbitraty proportion to make a zoom out of the data
    }
    
    func lineGraph(graph: BEMSimpleLineGraphView, didTouchGraphWithClosestIndex index: NSInteger) {
        let realIndex = realIndexForIndex(index)
        
        let date = fullDateLabelForIndex(realIndex)
        let value = fullValueForIndex(realIndex)
        var unit = axisYUnit!
        
        selectedValue = "\(value) \(unit) (\(date))"
        updateSelectedValueCell()
    }
    
    private func updateSelectedValueCell() {
        if details.count > 0 {
            let first = ChartDetailValue(label: "Touched Value", value: selectedValue)
            details[0] = first
            
            tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .None)
        }
    }
    
    private func updateDetails() {
        if let del = delegate {
            details = del.values()
            let first = ChartDetailValue(label: "Touched Value", value: selectedValue)
            let second = ChartDetailValue(label: "Samples", value: "\(values?.count ?? 0)")
            details.insert(second, atIndex: 0)
            details.insert(first, atIndex: 0)
            tableView.reloadData()
        }
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int  {
        return details.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as ChartDetailCell
        cell.label.textColor = Colors.lightGrayColor
        cell.value.textColor = color
        
        let value = details[indexPath.row] as ChartDetailValue
        
        cell.label.text = value.label
        cell.value.text = value.value
        
        return cell
    }
}
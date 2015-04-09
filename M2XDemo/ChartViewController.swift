//
//  ChartViewController.swift
//  M2XDemo
//
//  Created by Luis Floreani on 11/13/14.
//  Copyright (c) 2014 citrusbyte.com. All rights reserved.
//

import Foundation

@objc class ChartDetailValue: NSObject {
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
    @IBOutlet var containerView: UIView!
    @IBOutlet var separatorView: UIView!
    @IBOutlet var barView: UIView!
    @IBOutlet var tableView: UITableView!
    
    weak var delegate: ChartViewControllerDelegate?
    
    var axisXUnit: String?
    var axisYUnit: String?
    var minIndex: Int = 0
    var maxIndex: Int = 0
    var lastDateLabel: String = ""

    var values: [AnyObject]? {
        didSet {
            sliderView.enabled = values?.count > 0
        }
    }

    var details = [ChartDetailValue]()
    
    var valuesByRow = [Int: String]()

    var color: UIColor {
        set {
            graphView.colorTop = newValue
            graphView.colorBottom = newValue
            sliderView.tintColor = newValue
            separatorView.backgroundColor = newValue
            containerView.backgroundColor = newValue
            
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
        sliderView.backgroundColor = UIColor.clearColor()
        sliderLowerLabel.text = "--"
        sliderHigherLabel.text = "--"
        
        cacheLabel.alpha = 0
        deviceIdLabel.alpha = 0

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
        
        let font:UIFont? = UIFont(name: "ProximaNova-Bold", size: 13.0)
        graphView.labelFont = font
        
        updateDetails()
    }
    
    // MARK: Slider
    
    func updateOnNewValues() {
        minIndex = 0
        maxIndex = values != nil ? values!.count - 1 : 0
        
        if maxIndex > 0 {
            sliderView.minimumValue = 0
            sliderView.lowerValue = sliderView.minimumValue
            sliderView.maximumValue = Float(maxIndex)
            sliderView.upperValue = sliderView.maximumValue
        }
        
        self.updateDetails()

        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.graphView.alpha = 0.5
            self.sliderLowerLabel.alpha = 0
            self.sliderHigherLabel.alpha = 0
            self.deviceIdLabel.alpha = 0
        }) { (done: Bool) -> Void in
            self.updateSliderLabels(false)
            
            self.graphView.reloadGraph()
            
            UIView.animateWithDuration(1.0) {
                self.graphView.alpha = 1
                self.sliderLowerLabel.alpha = 1
                self.sliderHigherLabel.alpha = 1
                self.deviceIdLabel.alpha = 1
            }
        }
    }
    
    @IBAction func sliderDidChange(slider: NMRangeSlider) {
        if values == nil {
            return // in case the slider change while data is being loaded
        }
        
        minIndex = Int(slider.lowerValue)
        maxIndex = Int(slider.upperValue)
        
        updateSliderLabels(true)

        var timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: graphView, selector: Selector("reloadGraph"), userInfo: nil, repeats: false)
    }
    
    private func updateSliderLabels(updateDetail: Bool) {
        if numberOfPointsInLineGraph(graphView) > 0 {
            let minIndex = realIndexForIndex(0)
            let maxIndex = realIndexForIndex(numberOfPointsInLineGraph(graphView) - 1)
            
            let userFont = UIFontDescriptor.preferredFontDescriptorWithTextStyle(UIFontTextStyleBody)
            let userSize = userFont.pointSize
            
            if userSize == kDefaultBodySize {
                let font:UIFont? = UIFont(name: "Proxima Nova", size: 13.0)
                let fontBold:UIFont? = UIFont(name: "ProximaNova-Bold", size: 14.0)
                
                var str = fullDateLabelForIndex(minIndex)
                var attrString = NSMutableAttributedString(string: str)
                attrString.addAttribute(NSFontAttributeName, value: fontBold!, range: NSRange(location: 0,length: count(str.utf16) - 6))
                attrString.addAttribute(NSFontAttributeName, value: font!, range: NSRange(location: count(str.utf16) - 5,length: 5))
                sliderLowerLabel.attributedText = attrString
                
                str = fullDateLabelForIndex(maxIndex)
                attrString = NSMutableAttributedString(string: str)
                attrString.addAttribute(NSFontAttributeName, value: fontBold!, range: NSRange(location: 0,length: count(str.utf16) - 6))
                attrString.addAttribute(NSFontAttributeName, value: font!, range: NSRange(location: count(str.utf16) - 5,length: 5))
                sliderHigherLabel.attributedText = attrString
            } else {
                sliderLowerLabel.text = fullDateLabelForIndex(minIndex)
                sliderHigherLabel.text = fullDateLabelForIndex(maxIndex)
            }
            
            if updateDetail {
                updateDetails()
            }
        }
    }
    
    func minValue() -> Double {
        let minIndex = realIndexForIndex(0)

        return valueForIndex(minIndex)
    }
    
    func maxValue() -> Double {
        let maxIndex = realIndexForIndex(numberOfPointsInLineGraph(graphView) - 1)
        
        return valueForIndex(maxIndex)
    }
    
    // MARK: Graph
    
    func numberOfPointsInLineGraph(graph: BEMSimpleLineGraphView) -> NSInteger {
        return maxIndex - minIndex + 1
    }
    
    func numberOfGapsBetweenLabelsOnLineGraph(graph: BEMSimpleLineGraphView) -> NSInteger {
        let points = numberOfPointsInLineGraph(graphView)
        if points <= 3 {
            return 0
        } else if points % 2 == 0 {
            return  points / 3
        } else {
            return points / 4
        }
    }
    
    private func realIndexForIndex(index: NSInteger) -> NSInteger {
        return values!.count - 1 - minIndex - index
    }
    
    func lineGraph(graph: BEMSimpleLineGraphView, valueForPointAtIndex index: NSInteger) -> CGFloat {
        let realIndex = realIndexForIndex(index)
        let value = values?[realIndex] as! [String: AnyObject]
        let val = value["value"] as! Double
        let fl = Float(val)
        let ret = CGFloat(fl)
        return ret
    }
    
    private func dateLabelForIndex(index: NSInteger) -> String {
        let value = values?[index] as! [String: AnyObject]
        let timestamp = value["timestamp"] as! String
        
        let date = NSDate.fromISO8601(timestamp)
        let now = NSDate()

        let minValue = values?[minIndex] as! [String: AnyObject]
        let minTimestamp = minValue["timestamp"] as! String
        let minDate = NSDate.fromISO8601(minTimestamp)

        let maxValue = values?[maxIndex] as! [String: AnyObject]
        let maxTimestamp = maxValue["timestamp"] as! String
        let maxDate = NSDate.fromISO8601(maxTimestamp)
        
        var unit = ""
        var dateValue = 0
        var nowValue = ""
        if minDate.minutesFrom(maxDate) <= 1 {
            nowValue = "now"
            dateValue = Int(now.secondsFrom(date))
            unit = "sec"
        } else if minDate.hoursFrom(maxDate) <= 1 {
            nowValue = "now"
            dateValue = Int(now.minutesFrom(date))
            unit = "min"
        } else if minDate.daysFrom(maxDate) <= 1 {
            nowValue = "now"
            dateValue = Int(now.hoursFrom(date))
            unit = "hour"
        } else if minDate.weeksFrom(maxDate) <= 1 {
            nowValue = "today"
            dateValue = now.daysFrom(date)
            unit = "day"
        } else {
            nowValue = "this week"
            dateValue = now.weeksFrom(date)
            unit = "week"
        }
        
        var retValue = ""
        if dateValue == 0 {
            retValue = nowValue
        } else if dateValue == 1 {
            retValue = "\(dateValue) \(unit)"
        } else {
            retValue = "\(dateValue) \(unit)s"
        }
        
        if retValue == lastDateLabel {
            return ""
        } else {
            lastDateLabel = retValue
            return retValue
        }
    }

    private func fullDateLabelForIndex(index: NSInteger) -> String {
        let value = values?[index] as! [String: AnyObject]
        let timestamp = value["timestamp"] as! String
        
        if delegate?.formatDate != nil {
            return delegate!.formatDate!(timestamp)
        } else {
            let date = NSDate.fromISO8601(timestamp, timeZone: NSTimeZone.systemTimeZone(), locale: NSLocale.currentLocale())
            
            let formatted = date.formattedDateWithFormat("LLL d YYYY")
            
            return formatted
        }
    }
    
    private func fullValueForIndex(index: NSInteger) -> String {
        let val = valueForIndex(index)
        
        if delegate?.formatValue != nil {
            return delegate!.formatValue!(val)
        } else {
            return "\(val)"
        }
    }

    func valueForIndex(index: NSInteger) -> Double {
        let value = values?[index] as! [String: AnyObject]
        var doubleValue = value["value"] as! Double
        return Double(Int(doubleValue * 100))/100.0
    }
    
    func lineGraph(graph: BEMSimpleLineGraphView, labelOnXAxisForIndex index: NSInteger) -> NSString {
        let realIndex = realIndexForIndex(index)
        
        return dateLabelForIndex(realIndex)
    }
    
    func popUpValueForlineGraph(graph: BEMSimpleLineGraphView, atIndex: NSInteger) -> NSString {
        let realIndex = realIndexForIndex(atIndex)
        
        let date = fullDateLabelForIndex(realIndex)
        let value = fullValueForIndex(realIndex)
        var unit = axisYUnit!
        
        return "\(value) \(unit) (\(date))"
    }

    func minValueForLineGraph(graph: BEMSimpleLineGraphView) -> CGFloat {
        var min: CGFloat = CGFloat(INT16_MAX)
        
        for value in values! {
            var val = value["value"] as! CGFloat
            if val < min {
                min = val
            }
        }
        
        return min / 1.2 // arbitraty proportion to make a zoom out of the data
    }
    
    private func updateDetails() {
        if let del = delegate {
            details = del.values()
            
            let first = ChartDetailValue(label: "Samples", value: values?.count > 0 ? "\(numberOfPointsInLineGraph(graphView))" : "-")
            details.insert(first, atIndex: 0)
            tableView.reloadData()
        }
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int  {
        return details.count
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(tableView.bounds.size.height) / CGFloat(details.count)
    }

    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.separatorInset = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsetsZero
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! HBChartDetailCell
        cell.label.textColor = Colors.lightGrayColor
        cell.value.textColor = color
        cell.selectionStyle = .None
        
        let value = details[indexPath.row % details.count] as ChartDetailValue
        
        cell.label.text = value.label
        
        setNewValueAnimatedIfChanged(cell, indexPath: indexPath, newValue: value.value)

        return cell
    }
    
    
    func setNewValueAnimatedIfChanged(cell: HBChartDetailCell, indexPath: NSIndexPath, newValue: NSString) {
        var animated = false
        if let value = valuesByRow[indexPath.row] {
            if value != newValue {
                animated = true
                UIView.animateWithDuration(1.0, animations: {
                    cell.value.alpha = 0
                }) { (Bool) -> Void in
                    cell.value.text = newValue as? String
                    UIView.animateWithDuration(1.0, animations: {
                        cell.value.alpha = 1
                    })
                }
            }
        }
        
        if !animated {
            cell.value.text = newValue as? String
        }
        
        valuesByRow[indexPath.row] = newValue as? String
    }
}
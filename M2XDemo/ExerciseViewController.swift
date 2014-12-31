//
//  ExerciseViewController.swift
//  M2XDemo
//
//  Created by Luis Floreani on 11/11/14.
//  Copyright (c) 2014 citrusbyte.com. All rights reserved.
//

import UIKit

class ExerciseViewController: BaseViewController, ChartViewControllerDelegate {
    @IBOutlet var detailNoDataLabel: UILabel!

    private let model = DeviceData()
    private var client: M2XClient {
        var defaults = NSUserDefaults.standardUserDefaults()
        let key = defaults.valueForKey("key") as? String
        return M2XClient(apiKey: key!)
    }
    private var stream: M2XStream?
    private var deviceId: String?
    
    class var themeColor: UIColor {
        return Colors.exerciseColor
    }

    var chartViewController: ChartViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var nav = self.navigationController?.navigationBar
        nav?.barTintColor = ExerciseViewController.themeColor

        chartViewController?.view.alpha = 0
        detailNoDataLabel.alpha = 0
        detailNoDataLabel.textColor = Colors.grayColor

        ProgressHUD.showCBBProgress(status: "Loading Device")
        model.fetchDevice(DeviceType.Exercise) { [weak self] (device:M2XDevice?, values: [AnyObject]?, response: M2XResponse!) -> Void in
            ProgressHUD.hideCBBProgress()

            if response.error {
                self?.handleErrorAlert(response.errorObject!)
            } else {
                let cache = response.headers["X-Cache"] as NSString?
                if cache? == "HIT" {
                    let ghost = OLGhostAlertView(title: "Data from Cache", message: nil, timeout: 1.0, dismissible: true);
                    ghost.style = .Dark
                    ghost.show()

                    self?.chartViewController!.cached = true
                }

                self?.stream = M2XStream(client: self?.client, device: device, attributes: ["name": StreamType.Exercise.rawValue])
                self?.stream?.client?.delegate = self?.model // for cache

                self?.deviceId = device!["id"] as? String

                self?.chartViewController!.values = values
                
                self?.updateOnNewValuesAnimated()
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.hidden = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        ProgressHUD.cancelCBBProgress()
    }

    func updateOnNewValuesAnimated() {
        UIView.animateWithDuration(1.0) {
            self.updateOnNewValues()
        }
    }

    func updateOnNewValues() {
        let color = ExerciseViewController.themeColor
        chartViewController!.color = color
        chartViewController!.deviceIdLabel.text = "ID: Apple Watch"

        chartViewController!.updateOnNewValues()
        
        if chartViewController!.maxValue > 0 {
            chartViewController?.view.alpha = 1
        } else {
            detailNoDataLabel.alpha = 1
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let dc = segue.destinationViewController as? ChartViewController {
            chartViewController = dc
            chartViewController!.delegate = self
            chartViewController!.axisXUnit = "days"
            chartViewController!.axisYUnit = "mins"
        }
    }    

    // MARK: ChartVieWControllerDelegate
    
    func values() -> [ChartDetailValue] {
        let value = chartViewController!.valueForIndex(0)
        let today = "\(value!) \(chartViewController!.axisYUnit!)"
        
        var formatter = NSDateFormatter()
        formatter.dateStyle = .LongStyle
        let date = formatter.stringFromDate(NSDate())

        return [
            ChartDetailValue(label: "Goal", value: "30 Mins Daily, Low Impact"),
            ChartDetailValue(label: "Today", value: today),
            ChartDetailValue(label: "Date", value: date)
        ]
    }

}

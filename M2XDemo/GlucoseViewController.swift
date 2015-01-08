//
//  GlucoseViewController.swift
//  M2XDemo
//
//  Created by Luis Floreani on 11/11/14.
//  Copyright (c) 2014 citrusbyte.com. All rights reserved.
//

import UIKit

class GlucoseViewController: HBBaseViewController, ChartViewControllerDelegate {
    @IBOutlet var detailGoalLabel: UILabel!
    
    private let model = DeviceData()
    private var client: M2XClient {
        var defaults = NSUserDefaults.standardUserDefaults()
        let key = defaults.valueForKey("key") as? String
        return M2XClient(apiKey: key!)
    }
    private var deviceId: String?
    
    class var themeColor: UIColor {
        return Colors.glucoseColor
    }

    var chartViewController: ChartViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var nav = self.navigationController?.navigationBar
        nav?.barTintColor = GlucoseViewController.themeColor

        chartViewController!.color = GlucoseViewController.themeColor

        callWhenViewIsReady {
            
            if !DeviceData.isOffline() {
                let window = UIApplication.sharedApplication().delegate?.window!
                let center = self.chartViewController!.view.convertPoint(self.chartViewController!.containerView.center, toView:window)
                ProgressHUD.showCBBProgress(status: "Loading Device", center: center)
            }
            
            self.model.fetchDevice(HBDeviceTypeGlucose) { [weak self] (device: M2XDevice?, values: [AnyObject]?, response: M2XResponse!) -> Void in
                ProgressHUD.hideCBBProgress()
                
                if response.error {
                    HBBaseViewController.handleErrorAlert(response.errorObject!)
                } else {
                    let cache = response.headers["X-Cache"] as NSString?
                    if cache? == "HIT" {
                        let ghost = OLGhostAlertView(title: "Data from Cache", message: nil, timeout: 1.0, dismissible: true);
                        ghost.style = .Dark
                        ghost.show()
                        
                        self?.chartViewController!.cached = true
                    }
                    
                    self?.deviceId = device!["id"] as? String
                    
                    self?.chartViewController!.values = values
                    
                    self?.updateOnNewValuesAnimated()
                }
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
        chartViewController!.deviceIdLabel.text = "ID: Glucose Sensor"

        chartViewController!.updateOnNewValues()
        
        chartViewController?.view.alpha = chartViewController!.maxIndex > 0 ? 1 : 0
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let dc = segue.destinationViewController as? ChartViewController {
            chartViewController = dc
            chartViewController!.delegate = self
            chartViewController!.axisXUnit = "days"
            chartViewController!.axisYUnit = "mmol/L"
        }
    }
    
    // MARK: ChartVieWControllerDelegate
    
    func values() -> [ChartDetailValue] {
        var formatter = NSDateFormatter()
        formatter.dateStyle = .LongStyle
        let date = formatter.stringFromDate(NSDate())
        
        return [
            ChartDetailValue(label: "Goal", value: "below 7.8 mmol/L"),
            ChartDetailValue(label: "Date", value: date)
        ]
    }
}

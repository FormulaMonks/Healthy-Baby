//
//  WeightViewController.swift
//  M2XDemo
//
//  Created by Luis Floreani on 11/11/14.
//  Copyright (c) 2014 citrusbyte.com. All rights reserved.
//

import UIKit

class WeightViewController: BaseViewController, ChartViewControllerDelegate {
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
        return Colors.weightColor
    }
    
    var chartViewController: ChartViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var nav = self.navigationController?.navigationBar
        nav?.barTintColor = WeightViewController.themeColor

        chartViewController?.view.alpha = 0
        detailNoDataLabel.alpha = 0
        detailNoDataLabel.textColor = Colors.grayColor

        ProgressHUD.showCBBProgress(status: "Loading Device")
        model.fetchDevice(DeviceType.Weight) { [weak self] (device:M2XDevice?, values: [AnyObject]?, response: M2XResponse!) -> Void in
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

                self?.stream = M2XStream(client: self?.client, device: device, attributes: ["name": StreamType.Weight.rawValue])
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
        chartViewController!.deviceIdLabel.text = "ID: Fitbit Scale"
        let color = WeightViewController.themeColor
        chartViewController!.color = color

        chartViewController!.updateOnNewValues()
        
        chartViewController?.view.alpha = chartViewController!.maxValue > 0 ? 1 : 0
        detailNoDataLabel.alpha = chartViewController!.maxValue > 0 ? 0 : 1
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let dc = segue.destinationViewController as? ChartViewController {
            chartViewController = dc
            chartViewController!.delegate = self
            chartViewController!.axisXUnit = "weeks"
            chartViewController!.axisYUnit = "lb"
        }
    }
    
    // MARK: ChartVieWControllerDelegate
    
    func values() -> [ChartDetailValue] {
        var gain = "-"
        if chartViewController!.maxValue > 0 {
            let minMax = chartViewController!.minMaxValues()
            gain = "\(minMax.1 - minMax.0) lb"
        }

        return [
            ChartDetailValue(label: "Starting BMI", value: "30"),
            ChartDetailValue(label: "Goal", value: "13-17 lbs"),
            ChartDetailValue(label: "Baby Weight Gain", value: gain)
        ]
    }
}

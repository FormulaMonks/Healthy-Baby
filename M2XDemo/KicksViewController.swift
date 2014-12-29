//
//  File.swift
//  M2XDemo
//
//  Created by Luis Floreani on 11/17/14.
//  Copyright (c) 2014 citrusbyte.com. All rights reserved.
//

import Foundation
import Parse

class KicksViewController: BaseViewController, AddKickViewControllerDelegate, ChartViewControllerDelegate {
    @IBOutlet var detailNoDataLabel: UILabel!
    @IBOutlet var addButtonItem: UIBarButtonItem!
    @IBOutlet var triggerButtonItem: UIBarButtonItem!
    
    private let model = DeviceData(fromCache: true)
    private var client: M2XClient {
        var defaults = NSUserDefaults.standardUserDefaults()
        let key = defaults.valueForKey("key") as? String
        return M2XClient(apiKey: key!)
    }
    private var stream: M2XStream?
    private var deviceId: String?
    private var refreshKicks = false
    
    class var themeColor: UIColor {
        return Colors.kickColor
    }

    var chartViewController: ChartViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var nav = self.navigationController?.navigationBar
        nav?.barTintColor = KicksViewController.themeColor

        navigationItem.rightBarButtonItems = [addButtonItem, triggerButtonItem]
        addButtonItem.enabled = false
        triggerButtonItem.enabled = false

        detailNoDataLabel.textColor = Colors.grayColor

        chartViewController?.view.alpha = 0
        detailNoDataLabel.alpha = 0
        detailNoDataLabel.textColor = Colors.grayColor

        ProgressHUD.showCBBProgress(status: "Loading Device")
        model.fetchDevice(DeviceType.Kick) { [weak self] (device:M2XDevice?, values: [AnyObject]?, response: M2XResponse!) -> Void in
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

                self?.stream = M2XStream(client: self?.client, device: device, attributes: ["name": StreamType.Kick.rawValue])
                self?.stream?.client?.delegate = self?.model // for cache

                self?.deviceId = device!["id"] as? String
                self?.addButtonItem.enabled = true
                self?.triggerButtonItem.enabled = true
                
                self?.chartViewController!.values = values
                
                self?.updateOnNewValues()

                self?.updateInstallation()
            }
        }
    }
    
    func updateInstallation() {
        if let deviceId = self.deviceId {
            var installation = PFInstallation.currentInstallation()
            installation.setObject(deviceId, forKey: "kicksDeviceId")
            installation.saveInBackgroundWithBlock(nil)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        ProgressHUD.cancelCBBProgress()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if (refreshKicks) {
            loadData()
            refreshKicks = false
        }
    }
    
    func loadData() {
        ProgressHUD.showCBBProgress(status: "Loading Data")

        let params = ["limit": 1000]

        stream?.valuesWithParameters(params, completionHandler: { [weak self] (objects: [AnyObject]!, response: M2XResponse!) -> Void in
            ProgressHUD.hideCBBProgress()
            
            let cache = response.headers["X-Cache"] as NSString?
            if cache? == "HIT" {
                let ghost = OLGhostAlertView(title: "Data from Cache", message: nil, timeout: 1.0, dismissible: true);
                ghost.style = .Dark
                ghost.show()
                
                self?.chartViewController!.cached = true
            }
            
            if response.error {
                self?.handleErrorAlert(response.errorObject!)
            } else {
                self?.chartViewController!.values = objects
                
                self?.updateOnNewValuesAnimated()
            }
        })
    }
    
    func updateOnNewValuesAnimated() {
        UIView.animateWithDuration(1.0) {
            self.updateOnNewValues()
        }
    }

    func updateOnNewValues() {
        chartViewController!.deviceIdLabel.text = "ID: \(deviceId!)"
        let color = KicksViewController.themeColor
        chartViewController!.color = color
        chartViewController!.graphView.enableBezierCurve = false

        chartViewController!.updateOnNewValues()
        
        detailNoDataLabel.alpha = chartViewController!.maxValue > 0 ? 0 : 1
        
        if chartViewController!.maxValue > 0 {
            chartViewController?.view.alpha = 1
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let dc = segue.destinationViewController as? ChartViewController {
            chartViewController = dc
            chartViewController!.axisXUnit = "intervals"
            chartViewController!.axisYUnit = "kick"
            chartViewController!.delegate = self
        } else if let dc = segue.destinationViewController as? PreKickViewController {
            dc.deviceId = deviceId
            dc.delegate = self
        } else if let dc = segue.destinationViewController as? TriggersViewController {
            dc.deviceId = deviceId
        }
    }
    
    @IBAction func showTriggers(sender: AnyObject?) {
        let story = UIStoryboard(name: "Kick", bundle: nil)
        let vc = story.instantiateViewControllerWithIdentifier("Triggers") as TriggersViewController
        vc.deviceId = deviceId
        navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func startKicking(sender: AnyObject?) {
        let story = UIStoryboard(name: "Kick", bundle: nil)
        let vc = story.instantiateViewControllerWithIdentifier("StartKicking") as PreKickViewController
        vc.deviceId = deviceId
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: AddKickViewControllerDelegate
    
    func needsKicksRefresh() {
        refreshKicks = true
    }
    
    // MARK: ChartVieWControllerDelegate

    func values() -> [ChartDetailValue] {
        var formatter = NSDateFormatter()
        formatter.dateStyle = .LongStyle
        let date = formatter.stringFromDate(NSDate())
        
        return [
            ChartDetailValue(label: "Goal", value: "10 kicks in 2 hours"),
            ChartDetailValue(label: "Date", value: date)
        ]
    }

    func formatDate(timestamp: String) -> String {
        let date = NSDate.fromISO8601(timestamp)
        
        let formatted = date.formattedDateWithFormat("LLL dd YYYY HH:mm")

        return formatted
    }
    
    func formatValue(value: Double) -> String {
        return "\(Int(value))"
    }

}
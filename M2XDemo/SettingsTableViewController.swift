//
//  SettingsTableViewController.swift
//  M2XDemo
//
//  Created by Luis Floreani on 1/2/15.
//  Copyright (c) 2015 citrusbyte.com. All rights reserved.
//

import Foundation

class SettingsTableViewController: UITableViewController {
    @IBOutlet var textField: UITextField!;
    @IBOutlet var offlineSwitch: UISwitch!;
    
    let deviceData = DeviceData()

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        offlineSwitch.onTintColor = Colors.settingsColor
        
        var defaults = NSUserDefaults.standardUserDefaults()
        textField.text = defaults.valueForKey("key") as? String
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        saveKey()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        var defaults = NSUserDefaults.standardUserDefaults()
        if let offline = defaults.valueForKey("offline") as? Bool {
            offlineSwitch.setOn(offline, animated: true)
        }
    }

    private func saveKey() {
        var defaults = NSUserDefaults.standardUserDefaults()
        defaults.setValue(textField.text, forKey: "key")
        defaults.synchronize()
    }

    private func saveOfflineSetting() {
        var defaults = NSUserDefaults.standardUserDefaults()
        defaults.setValue(offlineSwitch.on, forKey:"offline")
    }

    private func validateKey() -> Bool {
        if textField.text.utf16Count > 0 {
            saveKey()

            return true
        } else {
            var alert = UIAlertController(title: "Missing Key", message: "Please fill the API Key field", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default) { (alert: UIAlertAction!) -> Void in
            })
            self.presentViewController(alert, animated: true, completion: nil)

            return false
        }
    }

    @IBAction func offlineChanged(sender: UISwitch) {
        if sender.on {
            if validateKey() {
                var hud = ProgressHUD.showCBBProgress(status: "Caching Data")
                hud.indeterminate = false
                deviceData.cacheAllData({ (response: M2XResponse!) -> Void in
                    ProgressHUD.hideCBBProgress()

                    if response.error {
                        sender.setOn(false, animated: true)

                        self.deviceData.deleteCache()

                        HBBaseViewController.handleErrorAlert(response.errorObject!)
                    } else {
                        self.saveOfflineSetting()
                    }
                }, progressHandler: { (progress: Float) -> () in
                    hud.setProgress(CGFloat(progress), animated: true)
                })
            } else {
                sender.setOn(false, animated: true)
            }
        } else {
            deviceData.deleteCache()

            self.saveOfflineSetting()
        }
    }

    @IBAction func deleteAll() {
        if validateKey() {
            var alert = UIAlertController(title: "Confirm", message: "Are you sure you want to delete ALL data?", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.Default) { (alert: UIAlertAction!) -> Void in
                ProgressHUD.showCBBProgress(status: "Deleting Data")

                self.deviceData.deleteCache()
                
                self.offlineSwitch.on = false
                
                self.saveOfflineSetting()

                self.deviceData.deleteAllData({ (response: M2XResponse!) -> Void in
                    ProgressHUD.hideCBBProgress()

                    if response.error {
                        HBBaseViewController.handleErrorAlert(response.errorObject!)
                    }
                })
                })
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default) { (alert: UIAlertAction!) -> Void in
                })
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    

}
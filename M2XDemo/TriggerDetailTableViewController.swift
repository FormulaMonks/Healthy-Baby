//
//  TriggerDetailTableViewController.swift
//  M2XDemo
//
//  Created by Luis Floreani on 1/6/15.
//  Copyright (c) 2015 citrusbyte.com. All rights reserved.
//

import Foundation

protocol TriggerDetailTableViewControllerDelegate : class {
    func triggerEditDone()
}

class TriggerDetailTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet private var nameLabel: UITextField!
    @IBOutlet private var valueLabel: UITextField!
    @IBOutlet private var conditionPicker: UIPickerView!
    @IBOutlet private var conditionLabel: UILabel!
    @IBOutlet private var callbackLabel: UITextField!
    @IBOutlet private var deleteButton: UIButton!
    
    var trigger: M2XTrigger?
    var device: M2XDevice?

    weak var delegate: TriggerDetailTableViewControllerDelegate?

    private let conditions = ["< is less than", "<= is less than or equal to", "= is equal to", "> is greater than", ">= is greater than or equal to"]
    private let conditionsValue = ["<", "<=", "=", ">", ">="]
    private var callbackUrl = "http://m2xdemo.parseapp.com/notify_trigger"
    private var callbackMockValue = "* WEBHOOK: can't edit this *"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assert(device != nil, "device can't be nil")
        
        if trigger != nil {
            nameLabel.text = trigger!["name"] as String
            valueLabel.text = trigger!["value"] as String
            let conditionIndex = find(conditionsValue, trigger!["condition"] as String)
            conditionPicker.selectRow(conditionIndex!, inComponent: 0, animated: true)
            conditionLabel.text = conditions[conditionIndex!]
            let url = trigger!["callback_url"] as String
            if url == callbackUrl {
                callbackLabel.text = callbackMockValue
                callbackLabel.enabled = false
            } else {
                callbackLabel.text = url
            }
        } else {
            conditionPicker.selectRow(conditions.count/2, inComponent: 0, animated: true)
            conditionLabel.text = conditions[conditions.count/2]
            callbackLabel.text = callbackMockValue
            callbackLabel.enabled = false
        }
    }
    
    @IBAction func delete() {
        var alert = UIAlertController(title: "Confirm", message: "Are you sure you want to delete this trigger?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.Default) { (alert: UIAlertAction!) -> Void in
            ProgressHUD.showCBBProgress(status: "Deleting Trigger")
            
            self.trigger?.deleteWithCompletionHandler({ (response: M2XResponse!) -> Void in
                ProgressHUD.hideCBBProgress()
                
                self.delegate?.triggerEditDone()
            })
            })
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default) { (alert: UIAlertAction!) -> Void in
            })
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func save() {
        if (nameLabel.text?.utf16Count == 0 || valueLabel.text?.utf16Count == 0 || callbackLabel.text?.utf16Count == 0) {
            var alert = UIAlertController(title: "Validation Failed", message: "Check your values they can't be empty!", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default) { (alert: UIAlertAction!) -> Void in
                })
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        nameLabel.resignFirstResponder()
        valueLabel.resignFirstResponder()
        callbackLabel.resignFirstResponder()
        
        var defaults = NSUserDefaults.standardUserDefaults()
        let key = defaults.valueForKey("key") as? String
        let dict = ["name": nameLabel.text, "stream": StreamType.Kick.rawValue, "condition": conditionsValue[conditionPicker.selectedRowInComponent(0)], "value": valueLabel.text, "callback_url": callbackLabel.text == callbackMockValue ? callbackUrl : callbackLabel.text, "status": "enabled"]
        if trigger != nil {
            ProgressHUD.showCBBProgress(status: "Updating Trigger")
            let triggerId = trigger!["id"] as String
            trigger?.updateWithParameters(dict, completionHandler: { (object: M2XResource!, response: M2XResponse!) -> Void in
                ProgressHUD.hideCBBProgress()
                
                if response.error {
                    HBBaseViewController.handleErrorAlert(response.errorObject!)
                    return
                }
                
                self.delegate?.triggerEditDone()
            })
        } else {
            ProgressHUD.showCBBProgress(status: "Creating Trigger")
            self.device?.createTrigger(dict, withCompletionHandler: { (object: M2XTrigger!, response: M2XResponse!) -> Void in
                ProgressHUD.hideCBBProgress()
                
                if response.error {
                    HBBaseViewController.handleErrorAlert(response.errorObject!)
                    return
                }
                
                self.delegate?.triggerEditDone()
            })
        }
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int  {
        if section == 0 {
            return 4
        } else if section == 1 {
            return 1
        } else {
            return trigger != nil ? 1 : 0
        }
    }
    
    // MARK: UIPickerViewDataSource
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        conditionLabel.text = conditions[row]
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return conditions.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return conditions[row]
    }

}
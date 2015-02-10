//
//  TriggerDetailViewController.swift
//  M2XDemo
//
//  Created by Luis Floreani on 11/24/14.
//  Copyright (c) 2014 citrusbyte.com. All rights reserved.
//

import Foundation

protocol TriggerDetailViewControllerDelegate : class {
    func needsTriggersRefresh()
}

class TriggerDetailViewController : HBBaseViewController, TriggerDetailTableViewControllerDelegate {
    @IBOutlet private var cancelButton: UIBarButtonItem!
    @IBOutlet private var saveButton: UIBarButtonItem!
    
    var trigger: M2XTrigger?
    var device: M2XDevice?

    var detail: TriggerDetailTableViewController!
    
    weak var delegate: TriggerDetailViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assert(device != nil, "device can't be nil")
        
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = saveButton
        
        if trigger != nil {
            saveButton.possibleTitles = NSSet(array: ["Update"]) as! Set<NSObject>
        } else {
            saveButton.possibleTitles = NSSet(array: ["Add"]) as! Set<NSObject>
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let dc = segue.destinationViewController as? TriggerDetailTableViewController {
            detail = dc
            detail.delegate = self
            detail.device = device
            detail.trigger = trigger
        }
    }
    
    @IBAction func save() {
        detail.save()
    }
    
    func triggerEditDone() {
        delegate?.needsTriggersRefresh()
        
        self.performSegueWithIdentifier("unwindMe", sender: self)
    }
}
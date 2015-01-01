//
//  ProfileViewController.swift
//  M2XDemo
//
//  Created by Luis Floreani on 11/11/14.
//  Copyright (c) 2014 citrusbyte.com. All rights reserved.
//

import UIKit

class ProfileViewController: HBBaseViewController {
    @IBOutlet var sexControl: UISegmentedControl!
    @IBOutlet var nameLabel: UITextField!
    @IBOutlet var dueLabel: UITextField!
    @IBOutlet var momHeight: UITextField!
    @IBOutlet var momWeight: UITextField!
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var formatter = NSDateFormatter()
        formatter.dateStyle = .LongStyle
        dueLabel.text = "\(formatter.stringFromDate(NSDate().dateByAddingMonths(2)))"
        
        var defaults = NSUserDefaults.standardUserDefaults()
        sexControl.selectedSegmentIndex = defaults.valueForKey("sex") as? Int ?? 0
        nameLabel.text = defaults.valueForKey("name") as? String
        momHeight.text = defaults.valueForKey("height") as? String
        momWeight.text = defaults.valueForKey("weight") as? String
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var defaults = NSUserDefaults.standardUserDefaults()
        defaults.setValue(sexControl.selectedSegmentIndex, forKey: "sex")
        defaults.setValue(nameLabel.text, forKey: "name")
        defaults.setValue(momHeight.text, forKey: "height")
        defaults.setValue(momWeight.text, forKey: "weight")
        defaults.synchronize()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

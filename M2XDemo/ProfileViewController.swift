//
//  ProfileViewController.swift
//  M2XDemo
//
//  Created by Luis Floreani on 11/11/14.
//  Copyright (c) 2014 citrusbyte.com. All rights reserved.
//

import UIKit

class ProfileViewController: HBBaseViewController {
//    @IBOutlet var sexControl: UISegmentedControl!
//    @IBOutlet var nameLabel: UITextField!
//    @IBOutlet var dueLabel: UITextField!
//    @IBOutlet var momHeight: UITextField!
//    @IBOutlet var momWeight: UITextField!
    @IBOutlet var navBar: UINavigationBar!;

    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBar.barTintColor = Colors.profileColor
        navBar.tintColor = UIColor.whiteColor()
        navBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        navBar.barStyle = UIBarStyle.Black
        
//        sexControl.tintColor = Colors.profileColor

//        var formatter = NSDateFormatter()
//        formatter.dateStyle = .LongStyle
//        dueLabel.text = "\(formatter.stringFromDate(NSDate().dateByAddingMonths(2)))"
//        
//        var defaults = NSUserDefaults.standardUserDefaults()
//        sexControl.selectedSegmentIndex = defaults.valueForKey("sex") as? Int ?? 0
//        nameLabel.text = defaults.valueForKey("name") as? String
//        momHeight.text = defaults.valueForKey("height") as? String
//        momWeight.text = defaults.valueForKey("weight") as? String
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

//        var defaults = NSUserDefaults.standardUserDefaults()
//        defaults.setValue(sexControl.selectedSegmentIndex, forKey: "sex")
//        defaults.setValue(nameLabel.text, forKey: "name")
//        defaults.setValue(momHeight.text, forKey: "height")
//        defaults.setValue(momWeight.text, forKey: "weight")
//        defaults.synchronize()

    }
}

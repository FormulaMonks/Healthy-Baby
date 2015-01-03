//
//  ProfileTableViewController.swift
//  M2XDemo
//
//  Created by Luis Floreani on 1/2/15.
//  Copyright (c) 2015 citrusbyte.com. All rights reserved.
//

import Foundation

class ProfileTableViewController: UITableViewController {
 
    @IBOutlet var nameLabel: UITextField!
    @IBOutlet var dueLabel: UILabel!
    @IBOutlet var momHeight: UITextField!
    @IBOutlet var momWeight: UITextField!
    
    @IBOutlet var boyCell: UITableViewCell!
    @IBOutlet var girlCell: UITableViewCell!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        boyCell.tintColor = Colors.profileColor
        girlCell.tintColor = Colors.profileColor
        
        var formatter = NSDateFormatter()
        formatter.dateStyle = .LongStyle
        dueLabel.text = "\(formatter.stringFromDate(NSDate().dateByAddingMonths(2)))"

        var defaults = NSUserDefaults.standardUserDefaults()
        let sex = defaults.valueForKey("sex") as? Int ?? 0
        boyCell.accessoryType = sex == 0 ? UITableViewCellAccessoryType.Checkmark : UITableViewCellAccessoryType.None
        girlCell.accessoryType = sex == 1 ? UITableViewCellAccessoryType.Checkmark : UITableViewCellAccessoryType.None
        nameLabel.text = defaults.valueForKey("name") as? String
        momHeight.text = defaults.valueForKey("height") as? String
        momWeight.text = defaults.valueForKey("weight") as? String
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        var defaults = NSUserDefaults.standardUserDefaults()
        defaults.setValue(boyCell.accessoryType == UITableViewCellAccessoryType.Checkmark ? 0 : 1, forKey: "sex")
        defaults.setValue(nameLabel.text, forKey: "name")
        defaults.setValue(momHeight.text, forKey: "height")
        defaults.setValue(momWeight.text, forKey: "weight")
        defaults.synchronize()
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            boyCell.accessoryType = indexPath.row == 0 ? UITableViewCellAccessoryType.Checkmark : UITableViewCellAccessoryType.None
            girlCell.accessoryType = indexPath.row == 1 ? UITableViewCellAccessoryType.Checkmark : UITableViewCellAccessoryType.None
        }
        
    }
}
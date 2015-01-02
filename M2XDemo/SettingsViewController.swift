//
//  SettingsViewController.swift
//  M2XDemo
//
//  Created by Luis Floreani on 11/14/14.
//  Copyright (c) 2014 citrusbyte.com. All rights reserved.
//

import Foundation

class SettingsViewController: HBBaseViewController {
    
    @IBOutlet var navBar: UINavigationBar!;
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navBar.barTintColor = Colors.settingsColor
        navBar.tintColor = UIColor.whiteColor()
        navBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        navBar.barStyle = UIBarStyle.Black
    }
}

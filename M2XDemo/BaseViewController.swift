//
//  BaseViewController.swift
//  M2XDemo
//
//  Created by Luis Floreani on 10/30/14.
//  Copyright (c) 2014 citrusbyte.com. All rights reserved.
//

import Foundation

class BaseViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.Black
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        nav?.setBackgroundImage(UIImage(), forBarPosition: .Any, barMetrics: .Default)
        nav?.backgroundColor = UIColor.whiteColor()
        nav?.translucent = false
        nav?.tintColor = UIColor.whiteColor()        
    }
        
    func handleErrorAlert(error: NSError) {
        var message: String = error.localizedDescription
        if error.localizedFailureReason != nil {
            message += ": \(error.localizedFailureReason!)"
        }
        var alert = UIAlertView(title: "Error", message: message, delegate: nil, cancelButtonTitle: "Ok")
        alert.show()
    }
}
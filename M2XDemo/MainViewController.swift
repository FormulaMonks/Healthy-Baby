//
//  MainViewController.swift
//  M2XDemo
//
//  Created by Luis Floreani on 11/11/14.
//  Copyright (c) 2014 citrusbyte.com. All rights reserved.
//

import Foundation
import Crashlytics

class MainViewController: HBBaseViewController {
    @IBOutlet var kickButton: UIButton!
    @IBOutlet var weightButton: UIButton!
    @IBOutlet var exerciseButton: UIButton!
    @IBOutlet var glucoseButton: UIButton!
    @IBOutlet var profileButton: UIButton!
    @IBOutlet var settingsButton: UIButton!
    
    @IBOutlet var kickBackground: UIView!
    @IBOutlet var weightBackground: UIView!
    @IBOutlet var exerciseBackground: UIView!
    @IBOutlet var glucoseBackground: UIView!
    @IBOutlet var profileBackground: UIView!
    @IBOutlet var settingsBackground: UIView!
    
    var buttons: [UIButton]! {
        return [kickButton, weightButton, exerciseButton, glucoseButton, profileButton, settingsButton]
    }
    
    var backgrounds: [UIView]! {
        return [kickBackground, weightBackground, exerciseBackground, glucoseBackground, profileBackground, settingsBackground]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.hidden = true
        
        kickBackground.backgroundColor = Colors.kickColor
        weightBackground.backgroundColor = Colors.weightColor
        exerciseBackground.backgroundColor = Colors.exerciseColor
        glucoseBackground.backgroundColor = Colors.glucoseColor
        profileBackground.backgroundColor = Colors.profileColor
        settingsBackground.backgroundColor = Colors.settingsColor
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "preferredContentSizeChanged:",
            name: UIContentSizeCategoryDidChangeNotification,
            object: nil)
    }
    
    func preferredContentSizeChanged(notification: NSNotification) {
        let userFont = UIFontDescriptor.preferredFontDescriptorWithTextStyle(UIFontTextStyleBody)
        let font = UIFont(name: "ProximaNova-Bold", size: userFont.pointSize)

        for background in backgrounds {
            for view in background.subviews {
                if let label = view as? UILabel {
                    label.font = font
                }
            }
        }
    }
    
    @IBAction func touchDown(sender: UIButton) {
        for button in buttons {
            button.superview?.alpha = 1.0
            if sender == button {
                button.superview?.alpha = 0.5
            }
        }
    }

    @IBAction func touchUp(sender: UIButton) {
        for button in buttons {
            button.superview?.alpha = 1.0
        }
        
        if sender == profileButton {
            showProfile(sender)
        } else if sender == settingsButton {
            showSettings(sender)
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.navigationBar.hidden = true
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == "ProfileSegue" || identifier == "SettingsSegue" {
            return true
        } else {
            var defaults = NSUserDefaults.standardUserDefaults()
            let key = defaults.valueForKey("key") as? String
            if key?.utf16Count > 0 {
                return true
            } else {
                var alert = UIAlertView(title: "Warning", message: "Please go to Settings and configure a key", delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
                return false
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        navigationController?.navigationBar.hidden = false
//        Crashlytics.sharedInstance().crash()
    }
    
    @IBAction func showSettings(sender: AnyObject?) {
        let story = UIStoryboard(name: "Settings", bundle: nil)
        let vc = story.instantiateViewControllerWithIdentifier("Settings") as! UIViewController
        presentViewController(vc, animated: true, completion: nil)
    }

    @IBAction func showProfile(sender: AnyObject?) {
        let story = UIStoryboard(name: "Settings", bundle: nil)
        let vc = story.instantiateViewControllerWithIdentifier("Profile") as! UIViewController
        presentViewController(vc, animated: true, completion: nil)
    }

    @IBAction func dismissFromSegue(segue: UIStoryboardSegue) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
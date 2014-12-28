//
//  MainViewController.swift
//  M2XDemo
//
//  Created by Luis Floreani on 11/11/14.
//  Copyright (c) 2014 citrusbyte.com. All rights reserved.
//

import Foundation
import Crashlytics

class MainViewController: BaseViewController {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.hidden = true
        
        kickBackground.backgroundColor = Colors.kickColor
        weightBackground.backgroundColor = Colors.weightColor
        exerciseBackground.backgroundColor = Colors.exerciseColor
        glucoseBackground.backgroundColor = Colors.glucoseColor
        profileBackground.backgroundColor = Colors.profileColor
        settingsBackground.backgroundColor = Colors.settingsColor
        
//        var image = UIImage(named: "WeightIcon")?.imageWithRenderingMode(.AlwaysTemplate)
//        weightButton.setImage(image, forState: .Normal)
//        weightButton.tintColor = WeightViewController.themeColor
//        weightButton.setTitleColor(weightButton.tintColor, forState: .Normal)
//
//        image = UIImage(named: "ExerciseIcon")?.imageWithRenderingMode(.AlwaysTemplate)
//        exerciseButton.setImage(image, forState: .Normal)
//        exerciseButton.tintColor = ExerciseViewController.themeColor
//        exerciseButton.setTitleColor(exerciseButton.tintColor, forState: .Normal)
//
//        image = UIImage(named: "GlucoseIcon")?.imageWithRenderingMode(.AlwaysTemplate)
//        glucoseButton.setImage(image, forState: .Normal)
//        glucoseButton.tintColor = GlucoseViewController.themeColor
//        glucoseButton.setTitleColor(glucoseButton.tintColor, forState: .Normal)
//
//        image = UIImage(named: "ActivityIcon")?.imageWithRenderingMode(.AlwaysTemplate)
//        kickButton.setImage(image, forState: .Normal)
//        kickButton.tintColor = KicksViewController.themeColor
//        kickButton.setTitleColor(kickButton.tintColor, forState: .Normal)

//        let offset = CGFloat(6.0)
//        let buttons = [weightButton, exerciseButton, kickButton, glucoseButton]
//        
//        for button in buttons {
//            let border = CALayer()
//            border.cornerRadius = 6
//            border.frame = CGRectMake(-offset * 2, -offset, button.frame.size.width + offset * 4, button.frame.size.height + offset * 2)
//            border.borderWidth = 1
//            border.borderColor = view.tintColor.CGColor
//            button.layer.addSublayer(border)
//        }
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
        let vc = story.instantiateViewControllerWithIdentifier("Settings") as UIViewController
        presentViewController(vc, animated: true, completion: nil)
    }

    @IBAction func showProfile(sender: AnyObject?) {
        let story = UIStoryboard(name: "Settings", bundle: nil)
        let vc = story.instantiateViewControllerWithIdentifier("Profile") as UIViewController
        presentViewController(vc, animated: true, completion: nil)
    }

    @IBAction func dismissFromSegue(segue: UIStoryboardSegue) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
//
//  AddKickViewController.swift
//  M2XDemo
//
//  Created by Luis Floreani on 11/17/14.
//  Copyright (c) 2014 citrusbyte.com. All rights reserved.
//

import Foundation

protocol AddKickViewControllerDelegate : class {
    func needsKicksRefresh()
}

class AddKickViewController : HBBaseViewController {
    @IBOutlet var detailGoalTitleLabel: UILabel!
    @IBOutlet var detailGoalLabel: UILabel!
    @IBOutlet var detailDateTitleLabel: UILabel!
    @IBOutlet var detailDateLabel: UILabel!
    @IBOutlet var currentIntervalTitleLabel: UILabel!
    @IBOutlet var kicksLabel: UILabel!
    @IBOutlet var kicksTitleLabel: UILabel!
    @IBOutlet var percentageLabel: UILabel!
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var addKickButton: MRoundedButton!
    @IBOutlet var progressView: M13ProgressViewPie!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var submitButton: UIButton!
    
    private var client: M2XClient {
        var defaults = NSUserDefaults.standardUserDefaults()
        let key = defaults.valueForKey("key") as? String
        return M2XClient(apiKey: key!)
    }

    private var kickCount = 0
    private let kickTotal = 10
    private let kickHours = 2
    
    private var timer: NSTimer?
    private var startTimerData: NSDate?
    
    var deviceId: String?
    weak var delegate: AddKickViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        assert(deviceId != nil, "deviceId can't be nil")
        
        addKickButton.alpha = 1
        cancelButton.alpha = 1
        submitButton.alpha = 1
        timerLabel.alpha = 1
        
        view.backgroundColor = Colors.backgroundColor

        var formatter = NSDateFormatter()
        formatter.dateStyle = .LongStyle
        detailDateLabel.text = "\(formatter.stringFromDate(NSDate()))"
        
        detailGoalTitleLabel.textColor = Colors.kickColor
        detailDateTitleLabel.textColor = Colors.kickColor
        detailGoalLabel.textColor = Colors.lightGrayColor
        detailDateLabel.textColor = Colors.lightGrayColor
        currentIntervalTitleLabel.textColor = Colors.kickColor
        kicksTitleLabel.textColor = Colors.lightGrayColor
        kicksLabel.textColor = Colors.grayColor
        percentageLabel.textColor = Colors.grayColor
        timerLabel.textColor = Colors.grayColor

        progressView.backgroundRingWidth = 0
        progressView.primaryColor = Colors.kickColor
        progressView.secondaryColor = UIColor.whiteColor()
        cancelButton.setTitleColor(Colors.kickColor, forState:.Normal)
        submitButton.setTitleColor(Colors.kickColor, forState:.Normal)
        
        startTimerData = NSDate()
        timer?.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target:self, selector:Selector("tick"), userInfo: nil, repeats: true)
        tick()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        ProgressHUD.cancelCBBProgress()
    }
    
    override func viewDidLayoutSubviews() {
        let newAddKickButton = MRoundedButton(frame: addKickButton.frame, buttonStyle: MRoundedButtonStyle.Default)
        newAddKickButton.addTarget(self, action: "addKickAction:", forControlEvents: UIControlEvents.TouchUpInside)
        newAddKickButton.addTarget(self, action: "touchDown:", forControlEvents: UIControlEvents.TouchDown)
        newAddKickButton.addTarget(self, action: "touchUp:", forControlEvents: UIControlEvents.TouchUpInside)
        newAddKickButton.addTarget(self, action: "touchUp:", forControlEvents: UIControlEvents.TouchUpOutside)
        newAddKickButton.textLabel.text = "ADD KICK"
        newAddKickButton.textLabel.font = UIFont(name:"Proxima Nova", size:26.0)
        newAddKickButton.contentColor = Colors.kickColor
        newAddKickButton.borderWidth = 0
        newAddKickButton.contentAnimateToColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
        newAddKickButton.foregroundColor = view.backgroundColor
        newAddKickButton.cornerRadius = newAddKickButton.frame.width/2
        newAddKickButton.borderColor = UIColor.lightGrayColor()
        newAddKickButton.alpha = addKickButton.alpha
        
        addKickButton.removeFromSuperview()
        addKickButton = newAddKickButton
        
        view.addSubview(addKickButton)
    }
    
    func tick() {
        let diff = Int(NSDate().timeIntervalSinceDate(startTimerData!))
        let hours = diff / 3600
        let mins = (diff / 60) % 60
        let seconds = diff % 60
        
        let hoursString = String(format: "%02d", hours)
        let minsStrings = String(format: "%02d", mins)
        let secondsString = String(format: "%02d", seconds)
        
        timerLabel.text = "\(hoursString):\(minsStrings):\(secondsString)"
        
        if hours >= kickHours {
            timeCompleted()
        }
    }
    
    private func timeCompleted() {
        timer!.invalidate()

        var alert = UIAlertController(title: "Time complete", message: "Time is up. Do you want to submit the kicks?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default) { (alert: UIAlertAction!) -> Void in
            self.performSegueWithIdentifier("unwindSegue", sender: self)
        })
        alert.addAction(UIAlertAction(title: "Send", style: UIAlertActionStyle.Default) { (alert: UIAlertAction!) -> Void in
            let date = NSDate()
            let values = [["value": self.kickCount, "timestamp": date.toISO8601()]]
            ProgressHUD.showCBBProgress(status: "Sending Value")
            
            let attributes = ["id" as NSObject: NSString(string: self.deviceId!)]
            let device = M2XDevice(client: self.client, attributes: attributes)
            let stream = M2XStream(client: self.client, device: device, attributes: ["name": StreamType.Kick.rawValue])

            stream.postValues(values, completionHandler: { (response: M2XResponse!) -> Void in
                ProgressHUD.hideCBBProgress()
                
                if response.error {
                    self.handleErrorAlert(response.errorObject!)
                } else {
                    self.delegate?.needsKicksRefresh()
                }

                self.performSegueWithIdentifier("unwindSegue", sender: self)
            })
        })
        self.presentViewController(alert, animated: true, completion: nil)
    }

    @IBAction func submitKicking(sender: AnyObject) {
        startTimerData = NSDate().dateBySubtractingHours(kickHours)
        tick()
    }
    
    @IBAction func touchDown(sender: AnyObject?) {
        addKickButton.foregroundColor = UIColor.lightGrayColor();
    }
    
    @IBAction func touchUp(sender: AnyObject?) {
        addKickButton.foregroundColor = UIColor.whiteColor();
    }

    func addKickAction(sender: AnyObject) {
        kickCount++
        let progress = CGFloat(Float(kickCount) / Float(kickTotal))
        progressView.setProgress(progress, animated: true)
        kicksLabel.text = "\(kickCount)"
        percentageLabel.text = "\(kickCount*10)%"
    }
}
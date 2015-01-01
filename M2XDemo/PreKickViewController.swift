//
//  PreKickViewController.swift
//  M2XDemo
//
//  Created by Luis Floreani on 12/9/14.
//  Copyright (c) 2014 citrusbyte.com. All rights reserved.
//

import Foundation

import Foundation

class PreKickViewController : HBBaseViewController, AddKickViewControllerDelegate {
    @IBOutlet var startCountingButton: UIButton!
    @IBOutlet var startCountingBackgroundView: UIView!
    @IBOutlet var header1Label: UILabel!
    @IBOutlet var header2Label: UILabel!

    var deviceId: String?

    weak var delegate: AddKickViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        assert(deviceId != nil, "deviceId can't be nil")

        header1Label.textColor = Colors.grayColor
        header2Label.textColor = Colors.lightGrayColor
        startCountingBackgroundView.layer.cornerRadius = startCountingBackgroundView.bounds.size.width/2
        startCountingButton.titleLabel!.textAlignment = .Center
        startCountingButton.setTitleColor(Colors.kickColor, forState:.Normal)
        startCountingButton.titleLabel!.font = UIFont(name:"Proxima Nova", size:26.0)
        
        view.backgroundColor = Colors.backgroundColor
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let dc = segue.destinationViewController as? AddKickViewController {
            dc.deviceId = deviceId
            dc.delegate = self
        }
    }
    
    func needsKicksRefresh() {
        self.delegate?.needsKicksRefresh()
    }
    
    @IBAction func touchDown(sender: AnyObject?) {
        startCountingBackgroundView.backgroundColor = UIColor.lightGrayColor();
    }

    @IBAction func touchUp(sender: AnyObject?) {
        startCountingBackgroundView.backgroundColor = UIColor.whiteColor();
    }

    @IBAction func dismissFromSegue(segue: UIStoryboardSegue) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

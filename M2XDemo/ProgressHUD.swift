//
//  M2XDemo
//
//  Created by Luis Floreani on 11/12/14.
//  Copyright (c) 2014 citrusbyte.com. All rights reserved.
//

import Foundation

let CBBProgresViewTag = 23452

class M2XHUD : M13ProgressHUD {
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        return nil // allow to touch on any other place of the UI without blocking
    }
}

@objc class ProgressHUD {
    class func showCBBProgress(status: String? = nil) -> M13ProgressHUD {
        let window = (UIApplication.sharedApplication().delegate as AppDelegate).window

        return ProgressHUD.showCBBProgress(status: status, center: window!.center)
    }
    
    class func showCBBProgress(status: String? = nil, center: CGPoint) -> M13ProgressHUD {
        let window = (UIApplication.sharedApplication().delegate as AppDelegate).window
        var hud = M2XHUD(progressView: M13ProgressViewRing())
        hud.primaryColor = UIColor.grayColor()
        hud.secondaryColor = UIColor.grayColor()
        hud.statusColor = UIColor.grayColor()
        hud.hudBackgroundColor = UIColor.whiteColor()
        hud.status = status
        hud.tag = CBBProgresViewTag
        hud.progressViewSize = CGSize(width: 60.0, height: 60.0)
        hud.indeterminate = true
        hud.animationPoint = window!.center
        if let view = window?.viewWithTag(CBBProgresViewTag) as? M13ProgressHUD {
            view.dismiss(true)
        }
        window?.addSubview(hud)
        hud.show(true)
        
        hud.center = center

        return hud
    }
    
    class func hideCBBProgress() {
        let window = (UIApplication.sharedApplication().delegate as AppDelegate).window
        dispatchDelayed(0.1) {
            if let hud = window?.viewWithTag(CBBProgresViewTag) as? M13ProgressHUD {
                hud.performAction(M13ProgressViewActionSuccess, animated: true)
                hud.indeterminate = false
                hud.dismiss(true)                
            }
        }
    }
    
    class func cancelCBBProgress() {
        let window = (UIApplication.sharedApplication().delegate as AppDelegate).window
        if let hud = window?.viewWithTag(CBBProgresViewTag) as? M13ProgressHUD {
            hud.performAction(M13ProgressViewActionFailure, animated: true)
            hud.indeterminate = false
            hud.dismiss(true)
        }
    }
    
    private class func dispatchDelayed(delay: Float, block: () -> Void) {
        let myDelay = Double(delay) * Double(NSEC_PER_SEC)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(myDelay)), dispatch_get_main_queue()) { () -> Void in
            block()
        }
    }

}
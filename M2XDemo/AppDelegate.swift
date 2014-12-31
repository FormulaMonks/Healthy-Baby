//
//  AppDelegate.swift
//  M2XDemo
//
//  Created by Luis Floreani on 10/28/14.
//  Copyright (c) 2014 citrusbyte.com. All rights reserved.
//

import UIKit
import Parse
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let migrationKey = "migration"

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        Crashlytics.startWithAPIKey("CRASHLYTICS_KEY_TOKEN");
        
        Parse.setApplicationId("PARSE_APP_ID_TOKEN", clientKey: "PARSE_CLIENT_KEY_TOKEN")
        
        if application.respondsToSelector("registerUserNotificationSettings:") {
            let settings = UIUserNotificationSettings(forTypes:.Badge | .Sound | .Alert, categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        } else {
            application.registerForRemoteNotificationTypes(.Badge | .Sound | .Alert)
        }
        
//        UILabel.appearance().font = UIFont(name:"Lucida Grande", size:1.0)
        let font = UIFont(name: "Proxima Nova", size: 22)
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: font!]
        
        initMigration()
        
        return true
    }
    
    func initMigration() {
        var defaults = NSUserDefaults.standardUserDefaults()
        
        let migration = defaults.valueForKey(migrationKey) as? Int

        if migration < 1 {
            migration1()
        }
        
        if (migration < 2) {
            // ...
        }
    }
    
    // since offline mode semantic changed, we set as false for old users
    func migration1() {
        var defaults = NSUserDefaults.standardUserDefaults()

        let device = DeviceData()
        device.deleteCache()
        defaults.setValue(false, forKey: "offline")
        
        defaults.setValue(1, forKey: migrationKey)
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData!) {
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveInBackgroundWithBlock(nil)
        println("registered for PN")
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError!) {
        println("Couldn't register: \(error)")
    }

    func application(application: UIApplication, didReceiveRemoteNotification info: NSDictionary!) {
        println("PN received")
        PFPush.handlePush(info)
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}


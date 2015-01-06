//
//  TriggersViewController.swift
//  M2XDemo
//
//  Created by Luis Floreani on 11/24/14.
//  Copyright (c) 2014 citrusbyte.com. All rights reserved.
//

import Foundation

class TriggersViewController : HBBaseViewController, TriggerDetailViewControllerDelegate, UITableViewDataSource, UITableViewDelegate {
    var deviceId: String?
    
    private var triggers: [AnyObject]?
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var addTriggerButton: UIBarButtonItem!
    @IBOutlet private var detailNoDataLabel: UILabel!
    private var refreshTriggers: Bool = false
    private var refreshControl: UIRefreshControl?
    private var device: M2XDevice?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        assert(deviceId != nil, "deviceId can't be nil")
        
        navigationItem.rightBarButtonItem = addTriggerButton
        
        detailNoDataLabel.alpha = 0
        detailNoDataLabel.textColor = Colors.grayColor

        refreshControl = UIRefreshControl()
        tableView.addSubview(refreshControl!)
        refreshControl!.addTarget(self, action: "loadData", forControlEvents: .ValueChanged)

        var defaults = NSUserDefaults.standardUserDefaults()
        let key = defaults.valueForKey("key") as? String
        let client = M2XClient(apiKey: key)
        self.device = M2XDevice(client: client, attributes: ["id": deviceId!])
        
        loadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let dc = segue.destinationViewController as? TriggerDetailViewController {
            dc.delegate = self
            dc.device = self.device

            if segue.identifier == "EditTriggerSegue" {
                let indexPath = self.tableView.indexPathForSelectedRow()
                let obj = self.triggers![indexPath!.row] as M2XTrigger
                dc.trigger = obj
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if (refreshTriggers) {
            loadData()
            refreshTriggers = false
        }
    }
    
    func loadData() {
        ProgressHUD.showCBBProgress(status: "Loading Data")
        
        device?.triggersWithCompletionHandler { (objects: [AnyObject]!, response: M2XResponse!) -> Void in
            ProgressHUD.hideCBBProgress()
            self.refreshControl?.endRefreshing()
            
            if response.error {
                HBBaseViewController.handleErrorAlert(response.errorObject!)
            } else {
                self.triggers = objects
                
                self.detailNoDataLabel.alpha = self.triggers?.count > 0 ? 0 : 1
                
                self.tableView.reloadData()
            }
        }
    }

    // MARK: TriggerDetailViewControllerDelegate
    
    func needsTriggersRefresh() {
        refreshTriggers = true
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 64.0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int  {
        return triggers?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        
        let obj = triggers![indexPath.row] as M2XTrigger
        
        let name = obj["name"] as String
        let condition = obj["condition"] as String
        let value: AnyObject = obj["value"]!
        
        cell.textLabel?.text = name
        cell.detailTextLabel?.text = "\(condition) \(value)"
        
        return cell
    }
    
    @IBAction func dismissFromSegue(segue: UIStoryboardSegue) {
        dismissViewControllerAnimated(true, completion: nil)
    }

}
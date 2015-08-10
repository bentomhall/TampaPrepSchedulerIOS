//
//  ScheduledNotificationsTableViewController.swift
//  TerpScheduler
//
//  Created by Ben Hall on 7/30/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import UIKit

class ScheduledNotificationsTableViewController: UITableViewController {
  @IBOutlet weak var titleView: UILabel?
  
  var notifications = UIApplication.sharedApplication().scheduledLocalNotifications as! [UILocalNotification]
  let calendar = NSCalendar.currentCalendar()
  let dateFormatter = NSDateFormatter()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    dateFormatter.dateFormat = "MM/dd/yyyy HH:mm"
    if notifications.count > 1 {
      titleView!.text = "\(notifications.count) Notifications Scheduled"
    } else if notifications.count == 1 {
      titleView!.text = "1 Notification Scheduled"
    } else {
      titleView!.text = "No Notifications Scheduled"
    }
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    // Return the number of sections.
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // Return the number of rows in the section.
    return notifications.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("NotificationCell", forIndexPath: indexPath) as! UITableViewCell
      let notification = notifications[indexPath.row]
      cell.textLabel!.text = notification.alertBody!
      cell.detailTextLabel!.text = dateFormatter.stringFromDate(notification.fireDate!)
    return cell
  }
  
  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
  }
  
  
  // Override to support editing the table view.
  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
      // Delete the row from the data source
      let notification = notifications[indexPath.row]
      notifications.removeAtIndex(indexPath.row)
      UIApplication.sharedApplication().cancelLocalNotification(notification)
      tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    } else if editingStyle == .Insert {
      // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
  }
  
  
}

//
//  ScheduledNotificationsTableViewController.swift
//  TerpScheduler
//
//  Created by Ben Hall on 7/30/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import UIKit
import UserNotifications

class ScheduledNotificationsTableViewController: UITableViewController {
  @IBOutlet weak var titleView: UILabel?

  var notificationCenter = UNUserNotificationCenter.current()
  let calendar = Calendar.current
  let dateFormatter = DateFormatter()
  var notifications: [UNNotificationRequest] = []

  override func viewDidLoad() {
    super.viewDidLoad()
    notifications.removeAll()
    notificationCenter.getPendingNotificationRequests(completionHandler: { requests in
      for request in requests {
        self.notifications.append(request)
      }})
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

  override func numberOfSections(in tableView: UITableView) -> Int {
    // Return the number of sections.
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // Return the number of rows in the section.
    return notifications.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath)
      let notification = notifications[(indexPath as NSIndexPath).row]
      cell.textLabel!.text = notification.content.body
    if let trigger = notification.trigger as? UNCalendarNotificationTrigger {
      let date = trigger.nextTriggerDate()!
      cell.detailTextLabel!.text = dateFormatter.string(from: date)
    }
    return cell
  }

  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }

  // Override to support editing the table view.
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      // Delete the row from the data source
      let notification = notifications[(indexPath as NSIndexPath).row]
      notifications.remove(at: (indexPath as NSIndexPath).row)
      notificationCenter.removePendingNotificationRequests(withIdentifiers: [notification.identifier])
      tableView.deleteRows(at: [indexPath], with: .fade)
    } else if editingStyle == .insert {
      // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
  }
}

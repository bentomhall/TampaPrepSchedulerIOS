//
//  TaskNotification.swift
//  TerpScheduler
//
//  Created by Ben Hall on 7/19/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import Foundation
import CoreData

func renumberBadge() {
  let application = UIApplication.sharedApplication()
  application.applicationIconBadgeNumber = 0
  var pendingNotifications = application.scheduledLocalNotifications as! [UILocalNotification]
  if pendingNotifications.count != 0 {
    application.cancelAllLocalNotifications()
    var badgeNumber = 1
    for notification in pendingNotifications {
      notification.applicationIconBadgeNumber = badgeNumber
      badgeNumber += 1
      application.scheduleLocalNotification(notification)
    }
  }
}

enum NotificationTimes: Int {
  //raw values are hours in 24-hr format
  case Evening = 19 //7PM
  case Morning = 9 // 9AM
  case Afternoon = 16 //4PM
  case Testing = -1 //for testing, set the time to 1 minute from now
}

class TaskNotification {
  private let task: DailyTask
  
  let UUID = NSUUID()
  
  init(task: DailyTask){
    self.task = task
  }
  
  private func notificationTime(fromCategory time: NotificationTimes)->NSDate{
    let calendar = NSCalendar.currentCalendar()
    if time != .Testing {
    let dueDate = calendar.dateBySettingHour(0, minute: 0, second: 0, ofDate: task.date, options: NSCalendarOptions())
    let notificationDate = calendar.dateByAddingUnit(.Day, value: -1, toDate: dueDate!, options: [])
    return calendar.dateBySettingHour(time.rawValue, minute: 0, second: 0, ofDate: notificationDate!, options: [])!
    } else {
      //Testing should set the notification for one minute from creation time
      let dueDate = NSDate()
      return calendar.dateByAddingUnit(.Minute, value: 1, toDate: dueDate, options: [])!
    }
  }
  
  func scheduleNotification(atTime time: NotificationTimes)->NSUUID? {
    let notificationDate = notificationTime(fromCategory: time)
    let nextBadgeNumber = UIApplication.sharedApplication().scheduledLocalNotifications.count + 1
    
    var notification = UILocalNotification()
    notification.alertBody = task.shortTitle
    notification.applicationIconBadgeNumber = nextBadgeNumber
    notification.alertAction = "view tasks"
    notification.fireDate = notificationDate
    notification.soundName = UILocalNotificationDefaultSoundName
    notification.userInfo = ["taskID": "\(task.shortTitle)\(task.period)"]
    notification.category = "taskReminderCategory"
    
    UIApplication.sharedApplication().scheduleLocalNotification(notification)
    return UUID
  }
}
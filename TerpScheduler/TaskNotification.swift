//
//  TaskNotification.swift
//  TerpScheduler
//
//  Created by Ben Hall on 7/19/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import Foundation
import CoreData

enum NotificationTimes: Int {
  //raw values are hours in 24-hr format
  case evening = 19 //7PM
  case morning = 9 // 9AM
  case afternoon = 16 //4PM
  case testing = -1 //for testing, set the time to 1 minute from now
}

class TaskNotification {
  fileprivate let task: DailyTask
  let UUID = Foundation.UUID()
  init(task: DailyTask) {
    self.task = task
  }

  fileprivate func notificationTime(fromCategory time: NotificationTimes) -> Date {
    let calendar = Calendar.current
    if time != .testing {
    let dueDate = (calendar as NSCalendar).date(bySettingHour: 0, minute: 0, second: 0, of: task.date as Date, options: NSCalendar.Options())
    let notificationDate = (calendar as NSCalendar).date(byAdding: .day, value: -1, to: dueDate!, options: [])
    return (calendar as NSCalendar).date(bySettingHour: time.rawValue, minute: 0, second: 0, of: notificationDate!, options: [])!
    } else {
      //Testing should set the notification for one minute from creation time
      let dueDate = Date()
      return (calendar as NSCalendar).date(byAdding: .minute, value: 1, to: dueDate, options: [])!
    }
  }

  func scheduleNotification(atTime time: NotificationTimes)->Foundation.UUID? {
    /*
    let notificationDate = notificationTime(fromCategory: time)
    let nextBadgeNumber = UIApplication.shared.scheduledLocalNotifications!.count + 1
    let notification = UILocalNotification()
    notification.alertBody = task.shortTitle
    notification.applicationIconBadgeNumber = nextBadgeNumber
    notification.alertAction = "view tasks"
    notification.fireDate = notificationDate
    notification.soundName = UILocalNotificationDefaultSoundName
    notification.userInfo = ["taskID": "\(task.shortTitle)\(task.period)"]
    notification.category = "taskReminderCategory"
    UIApplication.shared.scheduleLocalNotification(notification)
    return UUID*/
    return Foundation.UUID()
  }
}

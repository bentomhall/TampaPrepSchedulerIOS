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
  case Evening = 19 //7PM
  case Morning = 9 // 9AM
  case Afternoon = 16 //4PM
}

class TaskNotification {
  private let task: DailyTask
  
  let UUID = NSUUID()
  
  init(task: DailyTask){
    self.task = task
  }
  
  private func notificationTime(fromCategory time: NotificationTimes)->NSDate{
    let calendar = NSCalendar.currentCalendar()
    let dueDate = calendar.dateBySettingHour(0, minute: 0, second: 0, ofDate: task.date, options: NSCalendarOptions.allZeros)
    let notificationDate = calendar.dateByAddingUnit(.CalendarUnitDay, value: -1, toDate: dueDate!, options: .allZeros)
    return calendar.dateBySettingHour(time.rawValue, minute: 0, second: 0, ofDate: notificationDate!, options: .allZeros)!
  }
  
  func scheduleNotification(atTime time: NotificationTimes)->NSUUID? {
    let notificationDate = notificationTime(fromCategory: time)
    
    var notification = UILocalNotification()
    notification.alertBody = task.shortTitle
    notification.alertAction = "justInformAction"
    notification.fireDate = notificationDate
    notification.soundName = UILocalNotificationDefaultSoundName
    notification.userInfo = ["taskID": "\(task.shortTitle)\(task.period)"]
    notification.category = "taskReminderCategory"
    
    UIApplication.sharedApplication().scheduleLocalNotification(notification)
    return UUID
  }
}
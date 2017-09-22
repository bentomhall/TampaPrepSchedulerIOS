//
//  NotificationManager.swift
//  TerpScheduler
//
//  Created by Ben Hall on 9/19/17.
//  Copyright © 2017 Tampa Preparatory School. All rights reserved.
//

import Foundation
import UserNotifications

class NotificationManager {
  private var notificationCenter: UNUserNotificationCenter
  
  init() {
    notificationCenter = UNUserNotificationCenter.current()
  }
  
  func getDateForNotification(task: DailyTask, time: NotificationTimes) -> Date {
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
  
  func scheduleNotification(task: DailyTask, date: Date) {
    let identifier = UUID().uuidString
    let message = "Task \(task.shortTitle) is due tomorrow!"
    let components = Calendar.autoupdatingCurrent.dateComponents(Set([.day, .hour, .minute]), from: date)
    scheduleNotification(identifier: identifier, message: message, dateComponents: components)
  }
  
  func scheduleNotification(identifier: String, message: String, dateComponents: DateComponents) {
    let content = UNMutableNotificationContent()
    content.body = message
    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
    let notification = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
    self.notificationCenter.add(notification, withCompletionHandler: nil)
  }
  
  func cancelNotifications(matching: [String]) {
    if matching.count == 0 {
      self.notificationCenter.removeAllPendingNotificationRequests()
    } else {
      self.notificationCenter.removePendingNotificationRequests(withIdentifiers: matching)
    }
  }
}

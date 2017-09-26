//
//  NotificationManager.swift
//  TerpScheduler
//
//  Created by Ben Hall on 9/19/17.
//  Copyright © 2017 Tampa Preparatory School. All rights reserved.
//

import Foundation
import UserNotifications

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
  private var notificationCenter: UNUserNotificationCenter
  
  override init() {
    notificationCenter = UNUserNotificationCenter.current()
    super.init()
  }
  
  func getDateForNotification(task: DailyTask, time: NotificationTimes) -> Date {
    let calendar = Calendar.autoupdatingCurrent
    #if DEBUG
      let dueDate = Date()
      var components = DateComponents()
      components.minute = 1
      return calendar.date(byAdding: components, to: dueDate)!
    #else
      let dueDate = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: task.date)!
      let notificationDate = calendar.date(byAdding: .day, value: -1, to: dueDate)!
      var components = DateComponents()
      components.hour = time.rawValue
      return calendar.date(byAdding: components, to: notificationDate)!
    #endif
  }
  
  func scheduleNotification(task: DailyTask, date: Date) {
    if task.shortTitle == "" {
      return //fake call
    }
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
  
  func cancelNotification(matching: DailyTask) {
    if let id = getNotificationIdentifierFor(task: matching) {
      self.notificationCenter.removePendingNotificationRequests(withIdentifiers: [id])
    }
  }
  
  func getNotificationIdentifierFor(task: DailyTask) -> String? {
    var matched: String?
    notificationCenter.getPendingNotificationRequests(completionHandler: {requests in
      for request in requests {
        if request.content.body.contains(task.shortTitle) {
          matched = request.identifier
        }
      }
    })
    return matched
  }
  
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    completionHandler([.alert])
  }
}

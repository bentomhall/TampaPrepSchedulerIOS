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
    
    /// Determine the appropriate date to notify the user
    /// - Parameter task: The task of interest
    /// - Parameter time: From settings, one of morning/afternoon/evening
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
    
    /// Actually post the notification, convenience function. Returns without doing anything if the task does not have a title.
    /// - Parameter task: The task to notify about
    /// - Parameter date: The appropriate date.
  func scheduleNotification(task: DailyTask, date: Date) {
    if task.shortTitle == "" {
      return //fake call
    }
    if getNotificationIdentifierFor(task: task) != nil {
        return
    }
    let identifier = task.GUID ?? UUID().uuidString
    let message = "Task \(task.shortTitle) is due tomorrow!"
    let components = Calendar.autoupdatingCurrent.dateComponents(Set([.day, .hour, .minute]), from: date)
    scheduleNotification(identifier: identifier, message: message, dateComponents: components)
  }
  
  private func scheduleNotification(identifier: String, message: String, dateComponents: DateComponents) {
    let content = UNMutableNotificationContent()
    content.body = message
    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
    let notification = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
    self.notificationCenter.add(notification, withCompletionHandler: nil)
  }
    
    /// Cancels a set of notifications based on titles. Removes all if given an empty list.
    /// - Parameter matching: List of string titles to find and remove.
  func cancelNotifications(matching: [String]) {
    if matching.count == 0 {
      self.notificationCenter.removeAllPendingNotificationRequests()
    } else {
      self.notificationCenter.removePendingNotificationRequests(withIdentifiers: matching)
    }
  }
    
    /// Remove a single notification for a specific task
    /// - Parameter matching: The task to cancel the notification for.
  func cancelNotification(matching: DailyTask) {
    if let id = getNotificationIdentifierFor(task: matching) {
      self.notificationCenter.removePendingNotificationRequests(withIdentifiers: [id])
    }
  }
  
  private func getNotificationIdentifierFor(task: DailyTask) -> String? {
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

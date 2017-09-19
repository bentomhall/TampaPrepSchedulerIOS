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
  
  func scheduleNotification(message: String, dateComponents: DateComponents) {
    let content = UNMutableNotificationContent()
    content.body = message
    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
    let notification = UNNotificationRequest(identifier: "terpSchedule", content: content, trigger: trigger)
    self.notificationCenter.add(notification, withCompletionHandler: nil)
  }
  
  func cancelNotifications() {
    
  }
}

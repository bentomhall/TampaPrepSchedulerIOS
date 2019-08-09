//
//  UserDefaults.swift
//  TerpScheduler
//
//  Created by Ben Hall on 2/19/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import Foundation
import UIKit

extension Foundation.UserDefaults {
  func colorForKey(_ key: String) -> UIColor? {
    var color: UIColor?
    if let data = data(forKey: key) {
        try? color = NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? UIColor
    }
    return color
  }
  func setColor(_ color: UIColor?, forKey key: String) {
    var colorData: Data?
    if let color = color {
      try? colorData = NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false)
    }
    setValue(colorData, forKey: key)
  }
}

class CustomUserDefaults {
  fileprivate var defaults = Foundation.UserDefaults.standard
  var isDataInitialized: Bool {
    get { return defaults.bool(forKey: "isDataInitialized") }
    set(value) { defaults.set(value, forKey: "isDataInitialized") }
  }
  var isMiddleStudent: Bool {
    get { return defaults.bool(forKey: "isMiddleSchool") }
    set(value) { defaults.set(value, forKey: "isMiddleSchool") }
  }
  var shouldShadeStudyHall: Bool {
    get { return defaults.bool(forKey: "shouldShadeStudyHall") }
    set (value) { defaults.set(value, forKey: "shouldShadeStudyHall") }
  }
  var shouldDisplayExtraRow: Bool {
    get { return defaults.bool(forKey: "shouldShowExtraRow") }
    set (value) { defaults.set(value, forKey: "shouldShowExtraRow") }
  }
  var shouldNotifyWhen: NotificationTimes {
    get {
      switch defaults.string(forKey: "shouldNotifyWhen")! {
      case "Morning":
        return NotificationTimes.morning
      case "Afternoon":
        return NotificationTimes.afternoon
      case "Evening":
        return NotificationTimes.evening
      default:
        return NotificationTimes.testing
      }
    }
    set (value) {
      var stringValue = ""
      switch value {
      case .morning:
        stringValue = "Morning"
        break
      case .afternoon:
        stringValue = "Afternoon"
        break
      case .evening:
        stringValue = "Evening"
        break
      case .testing:
        break
      }
      defaults.setValue(stringValue, forKey: "shouldNotifyWhen")
    }
  }
  var noClassColor: UIColor? {
    get {
      return defaults.colorForKey("NoClassColor")
    }
    set(value) {
      defaults.setColor(value, forKey: "NoClassColor")
    }
  }
  var studyHallColor: UIColor? {
    get {
      return defaults.colorForKey("StudyHallColor")
    }
    set(value) {
      defaults.setColor(value, forKey: "StudyHallColor")
    }
  }
  var primaryThemeColor: UIColor? {
    get {
      return defaults.colorForKey("PrimaryThemeColor")
    }
    set(value) {
      defaults.setColor(value, forKey: "PrimaryThemeColor")
    }
  }
  func isFirstLaunchForCurrentVersion() -> Bool {
    guard let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
      return true
    }
    //test for nil, if it passes we can safely cast later
    if defaults.value(forKey: "version") == nil {
      defaults.setValue(currentVersion, forKey: "version")
      return true
    }
    guard let savedVersion = defaults.value(forKey: "version") as? String else {
      return true
    }
    if savedVersion == currentVersion {
      return false
    } else {
      return true
    }
  }
  func setFirstLaunch(_ value: Bool) {
    guard let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
      return
    }
    if value {
      defaults.removeObject(forKey: currentVersion)
    } else {
      defaults.setValue(currentVersion, forKey: "version")
    }
  }

  var lastScheduleUpdate: Double {
    get {
      return defaults.double(forKey: "lastScheduleUpdate")
    }
    set {
      defaults.setValue(newValue, forKey: "lastScheduleUpdate")
    }
  }

  var scheduleUpdateFrequency: Int {
    get {
      if let stored = defaults.value(forKey: "scheduleUpdateFrequency") {
        return stored as? Int ?? 60
      } else {
        return 60
      }

    }
    set {
      defaults.set(newValue, forKey: "scheduleUpdateFrequency")
    }
  }
  
  var colorTheme: Theme {
    get {
      if let stored = defaults.string(forKey: "colorTheme") {
        return Theme(rawValue: stored) ?? Theme.Light
      } else {
        return Theme.Light
      }
    }
    set {
      defaults.set(newValue.rawValue, forKey: "colorTheme")
    }
  }
  
  var decorationType: AssessmentDecorationType {
    if let stored = defaults.string(forKey: "assessmentDecorationType") {
      if stored == "None" {
        return AssessmentDecorationType.None
      } else if stored == "Highlight" {
        return AssessmentDecorationType.TextColor
      } else if stored == "Underline" {
        return AssessmentDecorationType.Underline
      } else if stored == "All Caps" {
        return AssessmentDecorationType.AllCaps
      } else {
        return AssessmentDecorationType.None
      }
    }
    return AssessmentDecorationType.None
  }
  
  var notificationPermissionGranted: Bool {
    get { return defaults.bool(forKey: "canNotify")}
    set { defaults.set(newValue, forKey: "canNotify")}
  }

  func onSettingsChange(_ notification: Notification) {
    readDefaults()
  }
  func readDefaults() {
    defaults.synchronize()
  }
  
}

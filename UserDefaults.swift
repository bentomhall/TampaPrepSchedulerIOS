//
//  UserDefaults.swift
//  TerpScheduler
//
//  Created by Ben Hall on 2/19/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import Foundation
import UIKit

extension NSUserDefaults {
  func colorForKey(key: String)->UIColor?{
    var color: UIColor?
    if let data = dataForKey(key){
      color = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? UIColor
    }
    return color
  }
  
  func setColor(color: UIColor?, forKey key: String){
    var colorData: NSData?
    if let color = color {
      colorData = NSKeyedArchiver.archivedDataWithRootObject(color)
    }
    setValue(colorData, forKey: key)
  }
}

class UserDefaults {
  private var defaults = NSUserDefaults.standardUserDefaults()
  
  var isDataInitialized: Bool {
    get { return defaults.boolForKey("isDataInitialized") }
    set(value) { defaults.setBool(value, forKey: "isDataInitialized") }
  }
  
  var isMiddleStudent: Bool {
    get { return defaults.boolForKey("isMiddleSchool") }
    set(value) { defaults.setBool(value, forKey: "isMiddleSchool") }
  }
  
  var shouldShadeStudyHall: Bool {
    get { return defaults.boolForKey("shouldShadeStudyHall") }
    set (value) { defaults.setBool(value, forKey: "shouldShadeStudyHall") }
  }
  
  var shouldDisplayExtraRow: Bool {
    get { return defaults.boolForKey("shouldShowExtraRow") }
    set (value) { defaults.setBool(value, forKey: "shouldShowExtraRow") }
  }
  
  var shouldNotifyWhen: NotificationTimes {
    get {
      switch(defaults.stringForKey("shouldNotifyWhen")!){
      case "Morning":
        return NotificationTimes.Morning
      case "Afternoon":
        return NotificationTimes.Afternoon
      case "Evening":
        return NotificationTimes.Evening
      default:
        return NotificationTimes.Testing
      }
    }
    set (value) {
      var stringValue = ""
      switch(value){
      case .Morning:
        stringValue = "Morning"
        break
      case .Afternoon:
        stringValue = "Afternoon"
        break
      case .Evening:
        stringValue = "Evening"
        break
      case .Testing:
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
    set(value){
      defaults.setColor(value, forKey: "PrimaryThemeColor")
    }
  }
  
  func isFirstLaunchForCurrentVersion()->Bool{
    let currentVersion = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as! String
    
    //test for nill, if it passes we can safely cast later
    if defaults.valueForKey("version") == nil {
      defaults.setValue(currentVersion, forKey: "version")
      return true
    }
    
    if (defaults.valueForKey("version") as! String) == currentVersion {
      return false
    } else {
      //defaults.setValue(currentVersion, forKey: "version")
      return true
    }
  }
  
  func setFirstLaunch(value: Bool){
    let currentVersion = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as! String
    if (value){
      defaults.removeObjectForKey(currentVersion)
    } else {
      defaults.setValue(currentVersion, forKey: "version")
    }
    
  }
  
  func onSettingsChange(notification: NSNotification){
    readDefaults()
  }
  
  func readDefaults(){
    defaults.synchronize()
  }
  
}

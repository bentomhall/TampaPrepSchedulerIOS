//
//  UserDefaults.swift
//  TerpScheduler
//
//  Created by Ben Hall on 2/19/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import Foundation
import UIKit

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
      defaults.setValue(currentVersion, forKey: "version")
      return true
    }
  }
  
  func readDefaults(){
    defaults.synchronize()
  }
  
}

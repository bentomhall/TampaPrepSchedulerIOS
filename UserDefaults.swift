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
  
}

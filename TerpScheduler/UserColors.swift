//
//  UserColors.swift
//  TerpScheduler
//
//  Created by Ben Hall on 8/14/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import Foundation
import UIKit

enum Theme: String {
  case Light
  case Dark
}

class UserColors {
  let defaults: CustomUserDefaults
  init(defaults: CustomUserDefaults) {
    self.defaults = defaults
  }

   var NoClassColor: UIColor {
    switch defaults.colorTheme {
    case .Light:
      return UIColor(white: 0, alpha: 0.1)
    case .Dark:
      return UIColor(white: 1, alpha: 0.9)
    }
  }

  var StudyHallColor: UIColor {
    switch defaults.colorTheme {
    case .Light:
      return UIColor(white: 0, alpha: 0.05)
    case .Dark:
      return UIColor(white: 1, alpha: 0.95)
    }
  }

  var primaryThemeColor: UIColor {
    return UIColor(red: 1, green: 0, blue: 0, alpha: 0.25)
  }
  
  var backgroundColor: UIColor {
    switch defaults.colorTheme {
    case .Light:
      return UIColor.groupTableViewBackground
    case .Dark:
      return UIColor(white: 0, alpha: 0.9)
    }
  }
  
  var cellColor: UIColor {
    switch defaults.colorTheme {
    case .Light:
      return UIColor.white
    case .Dark:
      return UIColor(white: 0, alpha: 0.8)
    }
  }
  
  var textColor: UIColor {
    switch defaults.colorTheme {
    case .Light:
      return UIColor.black
    case .Dark:
      return UIColor.white
    }
  }
}

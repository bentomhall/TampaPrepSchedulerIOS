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
      return self.backgroundColor
    }
  }

  var StudyHallColor: UIColor {
    switch defaults.colorTheme {
    case .Light:
      return UIColor(white: 0, alpha: 0.05)
    case .Dark:
      return self.backgroundColor
    }
  }

  var primaryThemeColor: UIColor {
    switch defaults.colorTheme {
    case .Light:
      return UIColor(red: 1, green: 0, blue: 0, alpha: 0.25)
    case .Dark:
      return UIColor(red: 1, green: 0, blue: 0, alpha: 0.75)
    }
  }
  
  var backgroundColor: UIColor {
    switch defaults.colorTheme {
    case .Light:
      return UIColor.groupTableViewBackground
    case .Dark:
      return UIColor(red: 0.153, green: 0.169, blue: 0.188, alpha: 1)
    }
  }
  
  var cellColor: UIColor {
    switch defaults.colorTheme {
    case .Light:
      return UIColor.white
    case .Dark:
      return UIColor(red: 0.196, green: 0.224, blue: 0.243, alpha: 1)
    }
  }
  
  var textColor: UIColor {
    switch defaults.colorTheme {
    case .Light:
      return UIColor.black
    case .Dark:
      return UIColor(red: 0.784, green: 0.784, blue: 0.784, alpha: 1) //#c8c8c8
    }
  }
}

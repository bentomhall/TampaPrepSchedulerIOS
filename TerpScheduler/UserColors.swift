//
//  UserColors.swift
//  TerpScheduler
//
//  Created by Ben Hall on 8/14/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import Foundation
import UIKit

class UserColors {
  let defaults: UserDefaults
  init(defaults: UserDefaults){
    self.defaults = defaults
  }
  
   var NoClassColor: UIColor {
    get {
      if let color = defaults.noClassColor {
        return color
      } else {
        return UIColor(white: 0, alpha: 0.1)
      }
    }
    
    set(value) {
      defaults.noClassColor = value
    }
  }
  
  var StudyHallColor: UIColor {
    get {
      if let color = defaults.studyHallColor {
        return color
      } else {
        return UIColor(white: 0, alpha: 0.05)
      }
    }
    set(value) {
      defaults.studyHallColor = value
    }
  }
  
  var primaryThemeColor: UIColor {
    get {
      if let color = defaults.primaryThemeColor {
        return color
      } else {
        return UIColor(red: 1, green: 0, blue: 0, alpha: 0.25)
      }
    }
  }
}

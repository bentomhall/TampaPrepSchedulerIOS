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
      if let color = defaults.NoClassColor {
        return color
      } else {
        return UIColor(white: 0, alpha: 0.1)
      }
    }
    
    set(value) {
      defaults.NoClassColor = value
    }
  }
  
  var StudyHallColor: UIColor {
    get {
      if let color = defaults.StudyHallColor {
        return color
      } else {
        return UIColor(white: 0, alpha: 0.05)
      }
    }
    set(value) {
      defaults.StudyHallColor = value
    }
  }
}

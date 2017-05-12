//
//  ScheduleTypeData.swift
//  TerpScheduler
//
//  Created by Ben Hall on 5/12/17.
//  Copyright © 2017 Tampa Preparatory School. All rights reserved.
//

import Foundation

class ScheduleTypeData {
  init(data: [String: Any]) {
    for (key, value) in data {
      if let missing = value as? [Int] {
        types[key] = missing
        var description = ""
        for period in [1, 2, 3, 4, 5, 6, 7] {
          if !missing.contains(period) {
            description += String(period) + ", "
          }
        }
        descriptions[key] = description
      }
    }
  }
  
  var scheduleTypes: [String] {
    var letters: [String] = []
    for key in Array(types.keys).sorted(by: <) {
      letters.append(key)
    }
    return letters
  }
  
  func scheduleForLetter(_ letter: String) -> String? {
    return descriptions[letter]
  }
  
  func scheduleForIndex(_ index: Int) -> String {
    let key = scheduleTypes[index]
    return key
  }
  
  var count: Int {
    return types.count
  }
  
  func getMissingClasses(type: String) -> [Int] {
    if let missing = types[type] {
      return missing
    }
    return [Int]() //unrecognized types are Y days
  }
  
  func getClassDescription(type: String) -> String {
    return descriptions[type] ?? ""
  }
  
  fileprivate var types = [String: [Int]]()
  fileprivate let periods = 7
  fileprivate var descriptions = [String: String]()
  
}

//
//  NetworkScheduleUpdater.swift
//  TerpScheduler
//
//  Created by Ben Hall on 4/27/17.
//  Copyright © 2017 Tampa Preparatory School. All rights reserved.
//

import Foundation

protocol ScheduleUpdateDelegate {
  func scheduleDidUpdateFromNetwork(newSchedule: [String: Any])
}

class NetworkScheduleUpdater {
  private let defaults: CustomUserDefaults
  private let delegate: ScheduleUpdateDelegate
  private var scheduleData: [String: Any]?
  
  init(defaults: CustomUserDefaults, delegate: ScheduleUpdateDelegate) {
    self.defaults = defaults
    self.delegate = delegate
  }
  
  func shouldUpdateFromNetwork() -> Bool {
    let lastUpdate = dateFromString(defaults.lastScheduleUpdate)
    let now = Date()
    return false //network side of things not active currently
    //return (Calendar.current.dateComponents([.day], from: lastUpdate, to: now).day ?? 0) > defaults.scheduleUpdateFrequency
  }
  
  func retrieveScheduleFromNetwork(withDefinitions: Bool, forYear: Int) {
    let url = URL(string: "http://teaching.admiralbenbo.org/schedules.php?\(forYear)")!
    
    let config = URLSessionConfiguration.default
    let session = URLSession(configuration: config)
    
    let task = session.dataTask(with: url, completionHandler: {
      (data, response, error) in
      if error != nil {
        
        print(error!.localizedDescription)
        
      } else {
        
        do {
          
          if let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]
          {
            guard json.count > 1 else {
              NSLog("Error retrieving schedule with message \(json["message"] ?? "Server Error")")
              return
            }
            
            self.delegate.scheduleDidUpdateFromNetwork(newSchedule: json)
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            self.defaults.lastScheduleUpdate = dateFormatter.string(from: Date())
          }
          
        } catch {
          
          print("error in JSONSerialization")
          
        }
      }
    })
    task.resume()
  }
  
  
}

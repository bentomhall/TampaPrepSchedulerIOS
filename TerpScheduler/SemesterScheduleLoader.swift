//
//  SemesterScheduleLoader.swift
//  TerpScheduler
//
//  Created by Ben Hall on 1/5/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import UIKit
import CoreData

class SemesterScheduleLoader: ScheduleUpdateDelegate {
  var context: NSManagedObjectContext
  weak var appDelegate: AppDelegate?
  var userDefaults: CustomUserDefaults
  var formatter = DateFormatter()

  init(context: NSManagedObjectContext) {
    let appDelegate = UIApplication.shared.delegate! as? AppDelegate
    self.context = context
    userDefaults = appDelegate!.userDefaults
  }

  func scheduleDidUpdateFromNetwork(newSchedule: [String : Any]) {
    _ = extractScheduleFrom(dict: newSchedule)
    do {
      try context.save()
    } catch let error as NSError {
      NSLog("%@", error)
    }
    setScheduleLoaded()
  }

  func loadSchedule(fromFiles files: [String]) {
    if !isScheduleLoaded() {
      for file in files {
        _ = loadScheduleDataFromJSON(file)
        do {
          try context.save()
        } catch let error as NSError {
          NSLog("%@", error)
        }
      }
      setScheduleLoaded()
    }
  }

  func loadScheduleDataFromJSON(_ jsonFileName: String) -> [NSManagedObject]? {
    if let path = Bundle.main.path(forResource: jsonFileName, ofType: "json") {
      let data: Data?
      do {
        data = try Data(contentsOf: URL(fileURLWithPath: path), options: NSData.ReadingOptions())
      } catch let error as NSError {
        data = nil
        NSLog("%@", error)
      }
      if let jsonData = try? JSONSerialization.jsonObject(with: data!, options: [.allowFragments]) as? [String : Any] {
        return extractScheduleFrom(dict: jsonData!)
      }
    }
    return nil
  }
  func extractScheduleFrom(dict: [String: Any]) -> [NSManagedObject] {
    var weeks = [] as [NSManagedObject]
    for (key, value) in dict {
      let weekLabel = key
      let weekInformation = value as? NSArray
      let weekSchedule = weekInformation![0] as? [String]
      let firstDay = weekInformation![1] as? String
      let entity = NSEntityDescription.entity(forEntityName: "Week", in: self.context)
      let managedWeek = WeekEntity(entity: entity!, insertInto: context)
      managedWeek.weekSchedules = serializeSchedule(weekSchedule!)
      managedWeek.weekID = NumberFormatter().number(from: weekLabel)!
      managedWeek.firstWeekDay = dateFromString(firstDay!)
      managedWeek.schoolYear = NSNumber(value: getSchoolYear(managedWeek.firstWeekDay))
      weeks.append(managedWeek)
    }
    return weeks
  }

  func isScheduleLoaded() -> Bool {
    userDefaults.setFirstLaunch(true) //temporary
    if userDefaults.isFirstLaunchForCurrentVersion() {
      return false
    } else {
      return userDefaults.isDataInitialized
    }
  }

  func setScheduleLoaded() {
    userDefaults.isDataInitialized = true
    userDefaults.setFirstLaunch(false)
  }

  func serializeSchedule(_ schedule: [String]) -> String {
    return schedule.joined(separator: " ")
  }
}

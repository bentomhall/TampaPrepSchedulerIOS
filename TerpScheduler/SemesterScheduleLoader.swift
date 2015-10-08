//
//  SemesterScheduleLoader.swift
//  TerpScheduler
//
//  Created by Ben Hall on 1/5/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import UIKit
import CoreData

class SemesterScheduleLoader{
  var context : NSManagedObjectContext
  let appDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
  var userDefaults: UserDefaults
  var formatter = NSDateFormatter()
  
  init(context: NSManagedObjectContext){
    self.context = context
    userDefaults = appDelegate.userDefaults
  }
  
  func loadSchedule(fromFiles files: [String]){
    if !isScheduleLoaded(){
      for file in files {
        loadScheduleDataFromJSON(file)
        do {
          try context.save()
        } catch let error as NSError {
          NSLog("%@", error)
        }
      }
      setScheduleLoaded()
    }
  }
  
  func loadScheduleDataFromJSON(jsonFileName: String)->[NSManagedObject]?{
    if let path = NSBundle.mainBundle().pathForResource(jsonFileName, ofType: "json"){
      let data: NSData?
      do {
        data = try NSData(contentsOfFile: path, options: NSDataReadingOptions())
      } catch let error as NSError {
        data = nil
        NSLog("%@", error)
      }
      let jsonData : NSDictionary = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)) as! NSDictionary
      var weeks = [] as [NSManagedObject]
      for (key, value) in jsonData {
        let weekLabel = key as! String
        let weekInformation = value as! NSArray
        let weekSchedule = weekInformation[0] as! [String]
        
        let firstDay = weekInformation[1] as! String
        let entity = NSEntityDescription.entityForName("Week", inManagedObjectContext: self.context)
        let managedWeek = WeekEntity(entity: entity!, insertIntoManagedObjectContext: context)
        managedWeek.weekSchedules = serializeSchedule(weekSchedule)
        managedWeek.weekID = Int(weekLabel)!
        managedWeek.firstWeekDay = dateFromString(firstDay)
        managedWeek.schoolYear = getSchoolYear(managedWeek.firstWeekDay)
        weeks.append(managedWeek)
      }
      
      return weeks
    }
    else{
      return nil
    }
  }
  
  func dateFromString(string: String)->NSDate{
    formatter.dateFormat = "MM/dd/yy"
    let date = formatter.dateFromString(string)!
    return date
  }
  
  func isScheduleLoaded()->Bool{
    if userDefaults.isFirstLaunchForCurrentVersion() {
      return false
    } else {
      return userDefaults.isDataInitialized
    }
  }
  
  func setScheduleLoaded(){
    userDefaults.isDataInitialized = true
  }
  
  func serializeSchedule(schedule: [String])->String{
    return schedule.joinWithSeparator(" ")
  }
}
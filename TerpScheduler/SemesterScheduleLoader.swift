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
  let appDelegate = UIApplication.sharedApplication().delegate! as AppDelegate
  var userDefaults: UserDefaults
  
  init(context: NSManagedObjectContext, withJSONFile: String){
    self.context = context
    userDefaults = appDelegate.userDefaults
    loadSemesterData(withJSONFile)
  }
  
  func loadSemesterData(jsonFileName: String){
    var error : NSError?
    if !isScheduleLoaded(){
      let weeks = loadScheduleDataFromJSON(jsonFileName)
      setScheduleLoaded()
      context.save(&error)
    }
  }
  
  func loadScheduleDataFromJSON(jsonFileName: String)->[NSManagedObject]?{
    var error: NSError?
    if let path = NSBundle.mainBundle().pathForResource(jsonFileName, ofType: "json"){
      let data = NSData(contentsOfFile: path, options: NSDataReadingOptions.allZeros, error: &error)
      let jsonData : NSDictionary = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: &error) as NSDictionary
      var weeks = [] as [NSManagedObject]
      for (key, value) in jsonData {
        let weekLabel = key as String
        let weekInformation = value as NSArray
        let weekSchedule = weekInformation[0] as [String]
        
        let firstDay = weekInformation[1] as String
        let entity = NSEntityDescription.entityForName("Week", inManagedObjectContext: self.context)
        var managedWeek = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: context)
        managedWeek.setValue(serializeSchedule(weekSchedule), forKey: "weekSchedules")
        managedWeek.setValue(weekLabel.toInt()!, forKey: "weekID")
        managedWeek.setValue(dateFromString(firstDay), forKey: "firstWeekDay")
        weeks.append(managedWeek)
      }
      
      return weeks
    }
    else{
      return nil
    }
  }
  
  func dateFromString(string: String)->NSDate{
    var formatter = NSDateFormatter()
    formatter.dateFormat = "MM/dd/yy"
    let date = formatter.dateFromString(string)!
    return date
  }
  
  func isScheduleLoaded()->Bool{
    return userDefaults.isDataInitialized
  }
  
  func setScheduleLoaded(){
    userDefaults.isDataInitialized = true
  }
  
  func serializeSchedule(schedule: [String])->String{
    return " ".join(schedule)
  }
}
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
  
  init(context: NSManagedObjectContext, withJSONFiles: [String]){
    self.context = context
    userDefaults = appDelegate.userDefaults
    if !isScheduleLoaded(){
      for file in withJSONFiles {
        let weeks = loadScheduleDataFromJSON(file)
        context.save(nil)
      }
      setScheduleLoaded()
    }
  }
  /*
  func loadSemesterData(jsonFileName: String){
    var error : NSError?
    if
      let weeks = loadScheduleDataFromJSON(jsonFileName)
      //setScheduleLoaded()
      context.save(&error)
    }
  }*/
  
  func loadScheduleDataFromJSON(jsonFileName: String)->[NSManagedObject]?{
    var error: NSError?
    if let path = NSBundle.mainBundle().pathForResource(jsonFileName, ofType: "json"){
      let data = NSData(contentsOfFile: path, options: NSDataReadingOptions.allZeros, error: &error)
      let jsonData : NSDictionary = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: &error) as! NSDictionary
      var weeks = [] as [NSManagedObject]
      for (key, value) in jsonData {
        let weekLabel = key as! String
        let weekInformation = value as! NSArray
        let weekSchedule = weekInformation[0] as! [String]
        
        let firstDay = weekInformation[1] as! String
        let entity = NSEntityDescription.entityForName("Week", inManagedObjectContext: self.context)
        var managedWeek = WeekEntity(entity: entity!, insertIntoManagedObjectContext: context)
        managedWeek.weekSchedules = serializeSchedule(weekSchedule)
        managedWeek.weekID = weekLabel.toInt()!
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
    return userDefaults.isDataInitialized
  }
  
  func setScheduleLoaded(){
    userDefaults.isDataInitialized = true
  }
  
  func serializeSchedule(schedule: [String])->String{
    return " ".join(schedule)
  }
}
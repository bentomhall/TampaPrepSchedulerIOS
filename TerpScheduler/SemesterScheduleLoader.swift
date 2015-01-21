//
//  SemesterScheduleLoader.swift
//  TerpScheduler
//
//  Created by Ben Hall on 1/5/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import Foundation
import CoreData

class SemesterScheduleLoader{
  var context : NSManagedObjectContext
  
  init(context: NSManagedObjectContext, withJSONFile: String){
    self.context = context
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
        managedWeek.setValue(sateFromString(firstDay), forKey: "firstWeekDay")
        weeks.append(managedWeek)
      }
      
      return weeks
    }
    else{
      return nil
    }
  }
  
  func sateFromString(string: String)->NSDate{
    var formatter = NSDateFormatter()
    formatter.dateFormat = "MM/dd/yy"
    let date = formatter.dateFromString(string)!
    return date
  }
  
  func isScheduleLoaded()->Bool{
    var value = false
    let HasLoadedFetchRequest = NSFetchRequest(entityName: "AppData")
    HasLoadedFetchRequest.returnsObjectsAsFaults = false
    if let appData = context.executeFetchRequest(HasLoadedFetchRequest, error: nil) as? [NSManagedObject] {
      if appData.count > 0 {
        
        value = appData[0].valueForKey("isScheduleLoaded") as Bool
      }
      else {
        let entity = NSEntityDescription.entityForName("AppData", inManagedObjectContext: context)
        var data = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: context)
        data.setPrimitiveValue(false, forKey: "isScheduleLoaded")
        value = false
      }
    }
    return value
  }
  
  func setScheduleLoaded(){
    let HasLoadedFetchRequest = NSFetchRequest(entityName: "AppData")
    HasLoadedFetchRequest.returnsObjectsAsFaults = false
    if let appData = context.executeFetchRequest(HasLoadedFetchRequest, error: nil) as? [NSManagedObject] {
      appData[0].setPrimitiveValue(true, forKey: "isScheduleLoaded")
      println(appData[0])
    }
  }
  
  func serializeSchedule(schedule: [String])->String{
    return " ".join(schedule)
  }
}
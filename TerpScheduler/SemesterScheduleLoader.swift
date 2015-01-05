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
    
    init(context: NSManagedObjectContext){
        self.context = context
        LoadSemesterData()
    }
    
    func LoadSemesterData(){
        let HasLoadedFetchRequest = NSFetchRequest(entityName: "AppData")
        var error : NSError?
        let appData = context.executeFetchRequest(HasLoadedFetchRequest, error: &error) as [NSManagedObject]?
        let hasLoaded : Bool = appData?[0].valueForKey("hasLoaded") as Bool
        if !hasLoaded{
            //extract information from json file
            LoadScheduleDataFromJSON()
        }
    }
    
    func LoadScheduleDataFromJSON(){
        var error: NSError?
        let path = NSBundle.mainBundle().pathForResource("winter2015.json", ofType: "json")
        let data = NSData(contentsOfFile: path!)
        let jsonData : NSDictionary = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: &error) as NSDictionary
        for (key, value) in jsonData {
            let weekLabel = key as String
            let weekInformation = value as NSArray
            let weekSchedule = weekInformation[0] as [String]
            var dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "M/d/YYYY"
            let firstDay = dateFormatter.dateFromString(weekInformation[1] as String)
            let entity = NSEntityDescription.entityForName("Week", inManagedObjectContext: self.context)
            var managedWeek = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: context)
            managedWeek.setValue(weekLabel.toInt(), forKey: "weekID")
            managedWeek.setValue(SerializeSchedule(weekSchedule), forKey: "weekSchedules")
            managedWeek.setValue(firstDay, forKey: "firstWeekDay")
        }
    }
    
    func SerializeSchedule(schedule: [String])->String{
        return " ".join(schedule)
    }
}
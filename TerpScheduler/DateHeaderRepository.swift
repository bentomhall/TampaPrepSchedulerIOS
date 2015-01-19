//
//  DailyTasksCollection.swift
//  TerpScheduler
//
//  Created by Ben Hall on 1/7/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import UIKit
import CoreData

struct SchoolDate {
  var Date : NSDate
  var Schedule : String
  static let _possibleSchedules : [String:[Int]] = ["A": [6], "B": [5,7], "C": [4],
    "D": [2], "E": [1,3],
    "X": [1, 2, 3, 4, 5, 6, 7],
    "Y": [], "A*": [4, 5, 6, 7],
    "A**": [1, 2, 3]]
  
  var ClassesMissed : [Int]? {
    get { return SchoolDate._possibleSchedules[Schedule] }
  }
  
  var dateString: String? {
    get{
      let formatter = NSDateFormatter()
      formatter.dateFormat = "MM/dd"
      return formatter.stringFromDate(Date)
    }
  }
}

class DateHeaderRepository: NSObject {
  var managedContext : NSManagedObjectContext
  var allTasks = [Int: [DailyTask]]()
  var weekID = -1
  var dates : [SchoolDate] = []
  var firstDate : NSDate {
    get { return dates[0].Date }
  }
  var lastDate : NSDate {
    get { return dates[dates.count - 1 ].Date }
  }
  
  func missedClassesForDay(index:Int)->[Int]?{
    return dates[index].ClassesMissed
  }
  
  init(context: NSManagedObjectContext){
    managedContext = context
    super.init()
    if weekID < 0 {
      weekID = fetchWeekID(NSDate()) //focus on current week
    }
    dates = LoadCurrentWeek()
  }
  
  func fetchWeekID(today: NSDate) ->Int {
    let calendar = NSCalendar.currentCalendar()
    let components = calendar.components(NSCalendarUnit.CalendarUnitWeekOfYear, fromDate: today)
    return components.weekOfYear
  }
  
  func LoadNextWeek(){
    weekID += 1
    dates = LoadCurrentWeek()
    return
  }
  
  func LoadPreviousWeek(){
    weekID -= 1
    dates = LoadCurrentWeek()
  }
  
  func LoadCurrentWeek()->[SchoolDate]{
    //called to populate the UI elements with current week's data
    
    var fetchRequest = NSFetchRequest(entityName: "Week")
    fetchRequest.returnsObjectsAsFaults = false
    fetchRequest.predicate = NSPredicate(format: "weekID = %i", weekID)
    var error : NSError?
    var dates: [SchoolDate] = []
    if let results = managedContext.executeFetchRequest(fetchRequest, error: nil) as? [WeekModel]{
      var weekData = results[0]
      let firstDay = weekData.firstWeekDay
      let schedule = weekData.weekSchedules.componentsSeparatedByString(" ")
      for (index, schedule) in enumerate(schedule) {
        let date = GetDateByOffset(firstDay, byOffset: index)
        dates.append(SchoolDate(Date: date, Schedule: schedule))
      }
    }
    return dates
  }
  
  func persistDates(){
    let fetchRequest = NSFetchRequest(entityName: "Week")
    fetchRequest.returnsObjectsAsFaults = false
    fetchRequest.predicate = NSPredicate(format: "weekID = %i", weekID)
    if let results = managedContext.executeFetchRequest(fetchRequest, error: nil) as? [WeekModel]{
      var schedules:[String] = []
      for day in dates{
        schedules.append(day.Schedule)
      }
      results[0].weekSchedules = " ".join(schedules)
      managedContext.save(nil)
    }
  }
  
  func setScheduleForDateByIndex(index: Int, newSchedule: String){
    dates[index].Schedule = newSchedule
    persistDates()
    return
  }
  
  func ScheduleForDateByIndex(index: Int)->String{
    return dates[index].Schedule
  }
  
  func GetDateByOffset(date : NSDate, byOffset index : Int)->NSDate{
    let offset = NSDateComponents()
    offset.day = index
    return NSCalendar.currentCalendar().dateByAddingComponents(offset, toDate: date, options: nil)!
  }
  
  func dateStringByIndex(index: Int)->String{
    return dates[index].dateString!
  }
}

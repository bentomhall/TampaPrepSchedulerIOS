//
//  DateRepository.swift
//  TerpScheduler
//
//  Created by Ben Hall on 1/21/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import Foundation
import CoreData

let possibleSchedules : [String:[Int]] = ["A": [6], "B": [5,7], "C": [4],
  "D": [2], "E": [1,3],
  "X": [1, 2, 3, 4, 5, 6, 7],
  "Y": [], "A*": [4, 5, 6, 7],
  "A**": [1, 2, 3]]

struct SchoolDate {
  var Date : NSDate
  var Schedule : String
  
  
  var ClassesMissed : [Int] {
    get {
      let missed = possibleSchedules[Schedule]
      if missed == nil {
        return []
      } else {
        return missed!
      }
    }
  }
  
  var dateString: String? {
    get{
      let formatter = NSDateFormatter()
      formatter.dateFormat = "MM/dd"
      return formatter.stringFromDate(Date)
    }
  }
}

class DateRepository {
  init(context: NSManagedObjectContext){
    entity = NSEntityDescription.entityForName("Week", inManagedObjectContext: context)!
    self.context = context
    fetchRequest = NSFetchRequest(entityName: "Week")
    fetchRequest.returnsObjectsAsFaults = false
    if weekID < 0 {
      weekID = fetchWeekID(NSDate())
    }

    dates = loadCurrentWeek()
  }
  
  private let fetchRequest: NSFetchRequest
  private let entity: NSEntityDescription
  private let context: NSManagedObjectContext
  
  private var weekID = -1
  var dates : [SchoolDate] = []
  var firstDate : NSDate {
    get { return dates[0].Date }
  }
  
  var lastDate : NSDate {
    get { return dates[dates.count - 1 ].Date }
  }
  
  func missedClassesForDay(index:Int)->[Int]{
    return dates[index].ClassesMissed
  }
  
  func fetchWeekID(today: NSDate) ->Int {
    let calendar = NSCalendar.currentCalendar()
    let components = calendar.components(NSCalendarUnit.CalendarUnitWeekOfYear, fromDate: today)
    return components.weekOfYear
  }
  
  func loadNextWeek(){
    if weekID == 19 {
      return
    }
    weekID += 1
    dates = loadCurrentWeek()
    return
  }
  
  func loadPreviousWeek(){
    if weekID == 1 {
      return
    }
    weekID -= 1
    dates = loadCurrentWeek()
  }
  
  func loadCurrentWeek()->[SchoolDate]{
    //called to populate the UI elements with current week's data
    var error : NSError?
    var dates: [SchoolDate] = []
    fetchRequest.predicate = NSPredicate(format: "weekID = %i", weekID)
    if let results = context.executeFetchRequest(fetchRequest, error: nil) as? [WeekEntity]{
      var weekData = results[0]
      let firstDay = weekData.firstWeekDay
      let schedule = weekData.weekSchedules.componentsSeparatedByString(" ")
      for (index, schedule) in enumerate(schedule) {
        let date = getDateByOffset(firstDay, byOffset: index)
        dates.append(SchoolDate(Date: date, Schedule: schedule))
      }
    }
    return dates
  }
  
  func persistDates(){
    if let results = context.executeFetchRequest(fetchRequest, error: nil) as? [WeekEntity]{
      var schedules:[String] = []
      for day in dates{
        schedules.append(day.Schedule)
      }
      results[0].weekSchedules = " ".join(schedules)
      context.save(nil)
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
  
  func getDateByOffset(date : NSDate, byOffset index : Int)->NSDate{
    let offset = NSDateComponents()
    offset.day = index
    return NSCalendar.currentCalendar().dateByAddingComponents(offset, toDate: date, options: nil)!
  }
  
  func dateStringByIndex(index: Int)->String{
    return dates[index].dateString!
  }


  
}

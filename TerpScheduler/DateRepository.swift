//
//  DateRepository.swift
//  TerpScheduler
//
//  Created by Ben Hall on 1/21/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import Foundation
import CoreData



///global-ish mapping from schedule types to a list of periods that DO NOT meet that day.
let possibleSchedules : [String:[Int]] = ["A": [6], "B": [5,7], "C": [4],
  "D": [2], "E": [1,3],
  "X": [1, 2, 3, 4, 5, 6, 7],
  "Y": [], "D*": [2, 5, 6, 7],
  "D**": [1, 2, 3, 4],
  "Y*": [5, 6, 7],
  "Y**": [1, 2, 3, 4],
  "C**": [1, 2, 3, 4],
  "C*": [4, 5, 6, 7],
  "C***": [2, 4, 6, 7]
]

struct SchoolDate {
  var Date : NSDate
  var Schedule : String
  let formatter = NSDateFormatter()
  var ClassesMissed : [Int] {
    get {
      let missed = possibleSchedules[Schedule]
      if missed == nil {
        //treat unknown days as X days (No classes meet)
        return possibleSchedules["X"]!
      } else {
        return missed!
      }
    }
  }
  var dateString: String? {
    get{
      formatter.dateFormat = "MM/dd"
      return formatter.stringFromDate(Date)
    }
  }
}

///Handles all date-related interactions. Fetches class schedules (ie what classes meet which days).
class DateRepository {
  init(context: NSManagedObjectContext){
    entity = NSEntityDescription.entityForName("Week", inManagedObjectContext: context)!
    self.context = context
    fetchRequest = NSFetchRequest(entityName: "Week")
    fetchRequest.returnsObjectsAsFaults = false
    let today = NSDate()
    schoolYear = getSchoolYear(today)
    currentSchoolYear = schoolYear
    if weekID < 0 {
      weekID = fetchWeekID(today)
    }
    dates = loadCurrentWeek()
  }
  
  private let fetchRequest: NSFetchRequest
  private let entity: NSEntityDescription
  private let context: NSManagedObjectContext
  private var schoolYear: Int //the school year associated with the date in view
  private let currentSchoolYear: Int //always the school year for todays date
  private let calendar = NSCalendar.currentCalendar()
  
  private var weekID = -1
  
  private func persistDates(){
    if let results = (try? context.executeFetchRequest(fetchRequest)) as? [WeekEntity]{
      var schedules:[String] = []
      for day in dates{
        schedules.append(day.Schedule)
      }
      results[0].weekSchedules = schedules.joinWithSeparator(" ")
      do {
        try context.save()
      } catch _ {
      }
    }
  }
  
  private func getDateByOffset(date : NSDate, byOffset index : Int)->NSDate{
    let offset = NSDateComponents()
    offset.day = index
    return NSCalendar.currentCalendar().dateByAddingComponents(offset, toDate: date, options: [])!
  }
  
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
    let components = calendar.components(NSCalendarUnit.WeekOfYear, fromDate: today)
    return components.weekOfYear
  }
  
  func loadNextWeek(){
    if weekID == 52 {
      weekID = 1
    } else if weekID == 22 {
      schoolYear += 1
      weekID += 1
    } else {
      weekID += 1
    }
    dates = loadCurrentWeek()
    return
  }
  
  func loadPreviousWeek(){
    if weekID == 23 {
      schoolYear -= 1
    } else if weekID == 1 {
      weekID = 52
    }
    weekID -= 1
    dates = loadCurrentWeek()
  }
  
  func isCurrentYear(week: WeekEntity)->Bool {
    let testYear = week.schoolYear
    return testYear == self.schoolYear
  }
  
  ///fetches the currently selected week's schedule.
  ///
  ///- returns: [SchoolDate] for all dates in the week.
  func loadCurrentWeek()->[SchoolDate]{
    var dates: [SchoolDate] = []
    fetchRequest.predicate = NSPredicate(format: "weekID = %i", weekID)
    if let results = (try? context.executeFetchRequest(fetchRequest)) as? [WeekEntity]{
      var weekData = results.filter(isCurrentYear)
      let firstDay = weekData[0].firstWeekDay
      let schedule = weekData[0].weekSchedules.componentsSeparatedByString(" ")
      for (index, schedule) in schedule.enumerate() {
        let date = getDateByOffset(firstDay, byOffset: index)
        dates.append(SchoolDate(Date: date, Schedule: schedule))
      }
    }
    return dates
  }
  
  func setScheduleForDateByIndex(index: Int, newSchedule: String){
    dates[index].Schedule = newSchedule
    persistDates()
    return
  }
  
  func loadWeekForDay(date: NSDate){
    weekID = fetchWeekID(date)
    dates = loadCurrentWeek()
    schoolYear = getSchoolYear(date)
  }
}

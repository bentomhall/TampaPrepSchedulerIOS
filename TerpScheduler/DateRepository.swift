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
  var Date : Foundation.Date
  var Schedule : String
  let formatter = DateFormatter()
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
      return formatter.string(from: Date)
    }
  }
}

///Handles all date-related interactions. Fetches class schedules (ie what classes meet which days).
class DateRepository {
  init(context: NSManagedObjectContext){
    entity = NSEntityDescription.entity(forEntityName: "Week", in: context)!
    self.context = context
    fetchRequest = NSFetchRequest(entityName: "Week")
    fetchRequest.returnsObjectsAsFaults = false
    let today = Date()
    schoolYear = getSchoolYear(today)
    currentSchoolYear = schoolYear
    if weekID < 0 {
      weekID = fetchWeekID(today)
    }
    dates = loadCurrentWeek()
  }
  
  fileprivate let fetchRequest: NSFetchRequest<WeekEntity>
  fileprivate let entity: NSEntityDescription
  fileprivate let context: NSManagedObjectContext
  fileprivate var schoolYear: Int //the school year associated with the date in view
  fileprivate let currentSchoolYear: Int //always the school year for todays date
  fileprivate let calendar = Calendar.current
  
  fileprivate var weekID = -1
  
  fileprivate func persistDates(){
    let results = (try! context.fetch(fetchRequest))
    var schedules:[String] = []
    for day in dates{
      schedules.append(day.Schedule)
    results[0].weekSchedules = schedules.joined(separator: " ")
    do {
        try context.save()
      } catch _ {
      }
    }
  }
  
  fileprivate func getDateByOffset(_ date : Date, byOffset index : Int)->Date{
    var offset = DateComponents()
    offset.day = index
    return (Calendar.current as NSCalendar).date(byAdding: offset, to: date, options: [])!
  }
  
  var dates : [SchoolDate] = []
  var firstDate : Date {
    get { return dates[0].Date }
  }
  
  var lastDate : Date {
    get { return dates[dates.count - 1 ].Date }
  }
  
  func missedClassesForDay(_ index:Int)->[Int]{
    return dates[index].ClassesMissed
  }
  
  func fetchWeekID(_ today: Date) ->Int {
    let components = (calendar as NSCalendar).components(NSCalendar.Unit.weekOfYear, from: today)
    return components.weekOfYear!
  }
  
  func loadNextWeek(){
    if weekID == 52 {
      weekID = 1
    } else if weekID == 22 {
      if schoolYear == currentSchoolYear {
        return //don't go off the end of the current year.
      }
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
  
  func isCurrentYear(_ week: WeekEntity)->Bool {
    let testYear = week.schoolYear as Int
    return testYear == self.schoolYear
  }
  
  ///fetches the currently selected week's schedule.
  ///
  ///- returns: [SchoolDate] for all dates in the week.
  func loadCurrentWeek()->[SchoolDate]{
    var dates: [SchoolDate] = []
    fetchRequest.predicate = NSPredicate(format: "weekID = %i", weekID)
    let results = (try! context.fetch(fetchRequest))
    var weekData = results.filter(isCurrentYear)
    let firstDay = weekData[0].firstWeekDay
    let schedule = weekData[0].weekSchedules.components(separatedBy: " ")
    for (index, schedule) in schedule.enumerated() {
      let date = getDateByOffset(firstDay, byOffset: index)
      dates.append(SchoolDate(Date: date, Schedule: schedule))
    }
    return dates
  }
  
  func setScheduleForDateByIndex(_ index: Int, newSchedule: String){
    dates[index].Schedule = newSchedule
    persistDates()
    return
  }
  
  func loadWeekForDay(_ date: Date){
    weekID = fetchWeekID(date)
    dates = loadCurrentWeek()
    schoolYear = getSchoolYear(date)
  }
}

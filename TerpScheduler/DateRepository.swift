//
//  DateRepository.swift
//  TerpScheduler
//
//  Created by Ben Hall on 1/21/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import Foundation
import CoreData

func dateFromString(_ string: String) -> Date {
  let formatter = DateFormatter()
  formatter.dateStyle = .short
  formatter.locale = Locale(identifier: "en_US")
  let date = formatter.date(from: string)!
  return date
}

/////global-ish mapping from schedule types to a list of periods that DO NOT meet that day.
//let possibleSchedules: [String:[Int]] = ["A": [6], "B": [5, 7], "C": [4],
//  "D": [2], "E": [1, 3],
//  "X": [1, 2, 3, 4, 5, 6, 7],
//  "Y": [], "D*": [2, 5, 6, 7],
//  "D**": [1, 2, 3, 4],
//  "Y*": [4, 5, 6, 7],
//  "Y**": [1, 2, 3 ],
//  "C**": [1, 2, 3, 4],
//  "C*": [4, 5, 6, 7],
//  "C***": [2, 4, 6, 7]
//]

struct SchoolDate {
  var Date: Foundation.Date
  var Schedule: String
  let formatter = DateFormatter()
  var ClassesMissed: [Int] {
    if let appDelegate = UIApplication.shared.delegate! as? AppDelegate {
      return appDelegate.scheduleTypes!.getMissingClasses(type: Schedule)
    }
    return [Int]()
  }
  
  var dateString: String? {
    formatter.dateFormat = "MM/dd"
    return formatter.string(from: Date)
  }
}

///Handles all date-related interactions. Fetches class schedules (ie what classes meet which days).
class DateRepository {
  init(context: NSManagedObjectContext) {
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

  fileprivate func persistDates() {
    let results = try? context.fetch(fetchRequest)
    var schedules: [String] = []
    for day in dates {
      schedules.append(day.Schedule)
    }
    if results != nil {
      results![0].weekSchedules = schedules.joined(separator: " ")
    }
    do {
        try context.save()
      } catch _ {
    }
  }

  fileprivate func getDateByOffset(_ date: Date, byOffset index: Int) -> Date {
    var offset = DateComponents()
    offset.day = index
    return (Calendar.current as NSCalendar).date(byAdding: offset, to: date, options: [])!
  }

  var dates: [SchoolDate] = []
  var firstDate: Date {
    return dates[0].Date
  }

  var lastDate: Date {
    return dates[dates.count - 1 ].Date
  }

  func missedClassesForDay(_ index: Int) -> [Int] {
    return dates[index].ClassesMissed
  }

  func fetchWeekID(_ today: Date) -> Int {
    let components = (calendar as NSCalendar).components(NSCalendar.Unit.weekOfYear, from: today)
    return components.weekOfYear!
  }

  func loadNextWeek() {
    if weekID == 52 {
      weekID = 1
    } else if weekID == 21 {
      if schoolYear != currentSchoolYear {
        schoolYear += 1
        weekID += 1 //don't go off the end of the current school-year.
      }
    } else {
      weekID += 1
    }
    dates = loadCurrentWeek()
    return
  }

  func loadPreviousWeek() {
    if weekID == 23 {
      schoolYear -= 1
    } else if weekID == 1 {
      weekID = 52
    }
    weekID -= 1
    dates = loadCurrentWeek()
  }

  func isCurrentYear(_ week: WeekEntity) -> Bool {
    return (week.schoolYear as? Int) == self.schoolYear
  }

  ///fetches the currently selected week's schedule.
  ///
  ///- returns: [SchoolDate] for all dates in the week.
  func loadCurrentWeek() -> [SchoolDate] {
    var dates: [SchoolDate] = []
    fetchRequest.predicate = NSPredicate(format: "weekID = %i", weekID)
    let results = try? context.fetch(fetchRequest)
    if results != nil {
      var weekData = results!.filter(isCurrentYear)
      let firstDay = weekData[0].firstWeekDay
      let schedule = weekData[0].weekSchedules.components(separatedBy: " ")
      for (index, schedule) in schedule.enumerated() {
        let date = getDateByOffset(firstDay, byOffset: index)
        dates.append(SchoolDate(Date: date, Schedule: schedule))
      }
      return dates
    } else {
      return [SchoolDate]()
    }
  }

  func setScheduleForDateByIndex(_ index: Int, newSchedule: String) {
    dates[index].Schedule = newSchedule
    persistDates()
    return
  }

  func loadWeekForDay(_ date: Date) {
    weekID = fetchWeekID(date)
    dates = loadCurrentWeek()
    schoolYear = getSchoolYear(date)
  }
  
  static func isScheduleLoadedFor(schoolYear: Int, inContext: NSManagedObjectContext) -> Bool {
    let fetchRequest = NSFetchRequest<WeekEntity>(entityName: "Week")
    let results = try? inContext.fetch(fetchRequest)
    if results != nil && results!.count != 0 {
      return true
    } else {
      return false
    }
  }
}

//
//  DateRepository.swift
//  TerpScheduler
//
//  Created by Ben Hall on 1/21/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import Foundation
import CoreData

/// Helper to convert a `String` into a `Date`. Locale-fixed to `en_US`.
///
/// - Parameter string: The MM/dd/yyyy date string.
/// - Returns: the `Date` object corresponding to the input string.
func dateFromString(_ string: String) -> Date {
  let formatter = DateFormatter()
  formatter.dateStyle = .short
  formatter.locale = Locale(identifier: "en_US")
  let date = formatter.date(from: string)!
  return date
}

struct SchoolDate {
  var Date: Foundation.Date
  var Schedule: String
  let formatter = DateFormatter()
  /// extracts a list of the classes that *don't* meet that day.
    var ClassesMissed: [Int] {
    if let appDelegate = UIApplication.shared.delegate! as? AppDelegate {
      return appDelegate.scheduleTypes!.getMissingClasses(type: Schedule)
    }
    return [Int]()
  }
  
  /// Display string in MM/dd format.
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
    
  /// The first day **in the week currently in view**
  var firstDate: Date {
    return dates[0].Date
  }

  /// The last day **in the week currently in view**
  var lastDate: Date {
    return dates[dates.count - 1 ].Date
  }
    
    /// The first date for the *school* year, June 1 YEAR.
    var firstDateForYear: Date {
        var dateComponents = DateComponents()
        dateComponents.year = schoolYear
        dateComponents.month = 6 // TerpScheduler starts its school year in June
        dateComponents.day = 1
        return Calendar.current.date(from: dateComponents)!
    }
    
    /// The last date for the *school* year, May 31 YEAR+1.
    var lastDateForYear: Date {
        var dateComponents = DateComponents()
        dateComponents.year = schoolYear + 1
        dateComponents.month = 5 // TerpScheduler starts its school year in June
        dateComponents.day = 31
        return Calendar.current.date(from: dateComponents)!
    }

    
  /// Get the classes that do not meet (and should be shaded as such) for a particular week-day (by index)
  ///
  /// - Parameter index: The day of the week (starting with Sunday = 1)
  /// - Returns: The class periods (1-indexed) that are missed.
  func missedClassesForDay(_ index: Int) -> [Int] {
    return dates[index].ClassesMissed
  }

  /// Gets the ISO week number for the indicated date.
  ///
  /// - Parameter today: The date in question. Usually the current date.
  /// - Returns: The ISO week number.
  func fetchWeekID(_ today: Date) -> Int {
    let components = (calendar as NSCalendar).components(NSCalendar.Unit.weekOfYear, from: today)
    return components.weekOfYear!
  }

  /// Sets the currently-active week (week in view) to the next week, stopping at the end of the school year.
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

  /// Sets the currently-active week (week in view) to the previous week, stopping at the beginning of the school year.
  func loadPreviousWeek() {
    if weekID == 23 {
      schoolYear -= 1
    } else if weekID == 1 {
      weekID = 52
    }
    weekID -= 1
    dates = loadCurrentWeek()
  }

  /// Tests if the given week in the current school year.
  ///
  /// - Parameter week: The `WeekEntity` of interest.
  /// - Returns: `true` if the school year matches the current one.
  func isCurrentYear(_ week: WeekEntity) -> Bool {
    return (week.schoolYear as? Int) == self.schoolYear
  }

  ///fetches the currently selected week's schedule.
  ///
  ///- Returns: [SchoolDate] for all dates in the week.
  func loadCurrentWeek() -> [SchoolDate] {
    var dates: [SchoolDate] = []
    fetchRequest.predicate = NSPredicate(format: "weekID = %i AND schoolYear = %i", weekID, schoolYear)
    let results = try? context.fetch(fetchRequest)
    if results != nil && results!.count > 0 {
      let weekData = results!.filter(isCurrentYear)
      let firstDay = weekData[0].firstWeekDay
      let schedule = weekData[0].weekSchedules.components(separatedBy: " ")
      for (index, schedule) in schedule.enumerated() {
        let date = getDateByOffset(firstDay, byOffset: index)
        dates.append(SchoolDate(Date: date, Schedule: schedule))
      }
      return dates
    } else {
      return createDefaultSchedule()
    }
  }

  /// Changes the schedule (letter) of the indicated day for the week in view.
  ///
  /// - Parameters:
  ///   - index: The day to change (indexed with 1 == sunday)
  ///   - newSchedule: The new letter (from ScheduleTypes.json) for the day.
  func setScheduleForDateByIndex(_ index: Int, newSchedule: String) {
    dates[index].Schedule = newSchedule
    persistDates()
    return
  }
  
  /// Generates a default schedule around the current week, setting all letters to Y (all classes meet).
  ///
  /// - Returns: A set of `SchoolDate` objects for the current week, with all schedules set to Y.
  func createDefaultSchedule() -> [SchoolDate] {
    var _dates = [SchoolDate]()
    var startDate = DateComponents()
    startDate.calendar = Calendar.current
    startDate.weekOfYear = weekID
    startDate.weekday = 2
    startDate.year = weekID < 23 ? schoolYear - 1 : schoolYear
    for index in 0...4 {
      let date = getDateByOffset(startDate.date!, byOffset: index)
      _dates.append(SchoolDate(Date: date, Schedule: "Y"))
    }
    return _dates
    
  }

  /// Set current week to the week matching the given date.
  ///
  /// - Parameter date: the desired date.
  func loadWeekForDay(_ date: Date) {
    weekID = fetchWeekID(date)
    schoolYear = getSchoolYear(date)
    dates = loadCurrentWeek()
  }
  
  /// Test if there is a valid schedule stored in the repository for the given school year. False on first load.
  ///
  /// - Parameters:
  ///   - schoolYear: The school year to test.
  ///   - inContext: `NSManagedObjectContext` for the repository
  /// - Returns: `true` if at least one result is fetched. `false` if zero are fetched.
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

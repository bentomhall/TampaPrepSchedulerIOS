//
//  TerpScheduler.swift
//  TerpScheduler
//
//  Created by Ben Hall on 1/13/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import Foundation
import CoreData

func getSchoolYear(date: NSDate)->Int{
  let flags: NSCalendarUnit = [NSCalendarUnit.WeekOfYear, NSCalendarUnit.Year, NSCalendarUnit.Month]
  let dateComponents = NSCalendar.currentCalendar().components(flags, fromDate: date)
  //1st week of june is currently the start of a new school year (by this system).
  let weekOfYear = dateComponents.weekOfYear
  
  //test for the case where the first official week of the year occurs in December.
  if weekOfYear >= 22 || (weekOfYear == 1 && dateComponents.month == 12){
    return dateComponents.year
  } else {
    return dateComponents.year - 1
  }
}

class WeekEntity: NSManagedObject {

  @NSManaged var firstWeekDay: NSDate
  @NSManaged var weekID: NSNumber
  @NSManaged var weekSchedules: String
  @NSManaged var schoolYear: NSNumber
}

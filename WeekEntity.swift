//
//  TerpScheduler.swift
//  TerpScheduler
//
//  Created by Ben Hall on 1/13/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import Foundation
import CoreData

func getSchoolYear(_ date: Date)->Int{
  let flags: NSCalendar.Unit = [NSCalendar.Unit.weekOfYear, NSCalendar.Unit.year, NSCalendar.Unit.month]
  let dateComponents = (Calendar.current as NSCalendar).components(flags, from: date)
  //1st week of june is currently the start of a new school year (by this system).
  let weekOfYear = dateComponents.weekOfYear
  
  //test for the case where the first official week of the year occurs in December.
  if weekOfYear! >= 22 || (weekOfYear! == 1 && dateComponents.month! == 12){
    return dateComponents.year!
  } else {
    return dateComponents.year! - 1
  }
}

class WeekEntity: NSManagedObject {

  @NSManaged var firstWeekDay: Date
  @NSManaged var weekID: NSNumber
  @NSManaged var weekSchedules: String
  @NSManaged var schoolYear: NSNumber
}

//
//  DailyTask.swift
//  TerpScheduler
//
//  Created by Ben Hall on 12/18/14.
//  Copyright (c) 2014 Tampa Preparatory School. All rights reserved.
//

import Foundation
import CoreData

func ==(lhs: DailyTaskData, rhs: DailyTaskData)->Bool {
  let isSameID = lhs.id == rhs.id
  let isSameData = lhs.due.compare(rhs.due) == NSComparisonResult.OrderedSame
  return isSameID && isSameData
}

enum Priorities: Int {
  case Highest = 0
  case High = 1
  case Medium = 2
  case Low = 3
  case Lowest = 4
  case Completed = 5
}

struct DailyTaskData: Equatable {
  let id : Int
  let due : NSDate
  let shortTitle : String
  let details : String
  let isHaikuAssignment : Bool
  let isCompleted : Bool
  let priority : Priorities
}

extension DailyTaskData{
  init(model: DailyTask){
    id = Int(model.id)
    due = model.dateDue
    shortTitle = model.shortTitle
    details = model.details
    isHaikuAssignment = Bool(model.isHaikuAssignment)
    isCompleted = Bool(model.isCompleted)
    priority = Priorities(rawValue: Int(model.priority))!
  }
}

class DailyTask: NSManagedObject {
  @NSManaged var forPeriod: NSNumber
  @NSManaged var dateDue: NSDate
  @NSManaged var classPeriod: NSNumber
  @NSManaged var shortTitle: String
  @NSManaged var details: String
  @NSManaged var isHaikuAssignment: NSNumber
  @NSManaged var isCompleted: NSNumber
  @NSManaged var priority: NSNumber
  @NSManaged var id: NSNumber

}

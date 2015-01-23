//
//  DailyTask.swift
//  TerpScheduler
//
//  Created by Ben Hall on 12/18/14.
//  Copyright (c) 2014 Tampa Preparatory School. All rights reserved.
//

import Foundation
import CoreData

enum Priorities: Int {
  case Highest = 0
  case High = 1
  case Medium = 2
  case Low = 3
  case Lowest = 4
  case Completed = 5
}

struct DailyTask: Filterable {
  let id: NSUUID
  let date: NSDate
  let period: Int
  let shortTitle : String
  let details : String
  let isHaikuAssignment : Bool
  let isCompleted : Bool
  let priority : Priorities
}

extension DailyTask{
  func dateIsBefore(other: DailyTask)->Bool{
    return (date.compare(other.date) == NSComparisonResult.OrderedAscending)
  }
  
  func periodIsBefore(other: DailyTask)->Bool{
    return period < other.period
  }
}

extension DailyTask: DataObject{
  init(entity: NSManagedObject){
    let model = entity as DailyTaskEntity
    id = NSUUID(UUIDString: model.id)!
    date = model.dateDue
    shortTitle = model.shortTitle
    details = model.details
    isHaikuAssignment = Bool(model.isHaikuAssignment)
    isCompleted = Bool(model.isCompleted)
    priority = Priorities(rawValue: Int(model.priority))!
    period = Int(model.forPeriod)
  }
  
  func toEntity(inContext context: NSManagedObjectContext)->NSManagedObject{
    let entity = NSEntityDescription.entityForName("DailyTask", inManagedObjectContext: context)
    let managedEntity = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: context) as DailyTaskEntity
    managedEntity.details = details
    managedEntity.shortTitle = shortTitle
    managedEntity.forPeriod = period
    managedEntity.dateDue = date
    managedEntity.isCompleted = isCompleted
    managedEntity.isHaikuAssignment = isHaikuAssignment
    managedEntity.priority = priority.rawValue
    managedEntity.id = id.UUIDString
    return managedEntity as NSManagedObject
  }
}

struct TaskSummary {
  let title: String
  let remainingTasks: Int
  static let DefaultSummary: TaskSummary = TaskSummary(title: "No Tasks", remainingTasks: 0)
}

class DailyTaskEntity: NSManagedObject {
  @NSManaged var forPeriod: NSNumber
  @NSManaged var dateDue: NSDate
  @NSManaged var shortTitle: String
  @NSManaged var details: String
  @NSManaged var isHaikuAssignment: NSNumber
  @NSManaged var isCompleted: NSNumber
  @NSManaged var priority: NSNumber
  @NSManaged var id: String

}

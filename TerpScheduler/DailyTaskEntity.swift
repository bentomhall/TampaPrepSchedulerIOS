//
//  DailyTask.swift
//  TerpScheduler
//
//  Created by Ben Hall on 12/18/14.
//  Copyright (c) 2014 Tampa Preparatory School. All rights reserved.
//

import Foundation
import CoreData

func ==(lhs: DailyTask, rhs: DailyTask)->Bool {
  let isTitleSame = lhs.shortTitle == rhs.shortTitle
  let isDetailsSame = lhs.details == rhs.details
  let isPrioritySame = lhs.priority == rhs.priority
  let isCompletionStatusSame = lhs.isCompleted == rhs.isCompleted
  let isHaikuStatusSame = lhs.isHaikuAssignment == rhs.isHaikuAssignment
  let isNotificationStatusSame = lhs.shouldNotify == rhs.shouldNotify
  return isTitleSame && isDetailsSame && isPrioritySame && isCompletionStatusSame && isHaikuStatusSame && isNotificationStatusSame
}

enum Priorities: Int {
  case Highest = 0
  case High = 1
  case Medium = 2
  case Low = 3
  case Lowest = 4
  case Completed = 5
}

struct DailyTask: Filterable, Equatable {
  var id: NSManagedObjectID?
  let date: NSDate
  let period: Int
  var shortTitle : String
  var details : String
  var isHaikuAssignment : Bool
  var isCompleted : Bool
  var priority : Priorities
  var shouldNotify: Bool
  
  init(date: NSDate, period: Int, shortTitle: String, details: String, isHaiku: Bool, completion: Bool, priority: Priorities, notify: Bool){
    self.date = date
    self.period = period
    self.shortTitle = shortTitle
    self.details = details
    self.isCompleted = completion
    self.isHaikuAssignment = isHaiku
    self.priority = priority
    self.shouldNotify = notify
  }
  
  func contentsAsDictionary()->[String: AnyObject]{
    var contentDictionary = [String: AnyObject]()
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "MM/dd/yyyy"
    contentDictionary["date"] = dateFormatter.stringFromDate(self.date)
    contentDictionary["period"] = self.period
    contentDictionary["shortTitle"] = self.shortTitle
    contentDictionary["details"] = self.details
    contentDictionary["isCompleted"] = Int(self.isCompleted)
    contentDictionary["priority"] = self.priority.rawValue
    contentDictionary["isHaikuAssignment"] = Int(self.isHaikuAssignment)
    contentDictionary["shouldNotify"] = Int(self.shouldNotify)
    return contentDictionary
  }
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
    let model = entity as! DailyTaskEntity
    let context = model.managedObjectContext!
    context.save(nil)
    id = model.objectID
    date = model.dateDue
    shortTitle = model.shortTitle
    details = model.details
    isHaikuAssignment = Bool(model.isHaikuAssignment)
    isCompleted = Bool(model.isCompleted)
    priority = Priorities(rawValue: Int(model.priority))!
    period = Int(model.forPeriod)
    shouldNotify = false
  }
  
  ///returns managed entity associated with this data in the provided context. Only creates new if no entity with this id already exists.
  ///
  ///:param: inContext The NSManagedObjectContext to put the entity in.
  ///:returns: A NSManagedObject containing the data from self.
  func toEntity(inContext context: NSManagedObjectContext)->NSManagedObject{
    if self.id != nil{
      // If a entity with this id already exists, return it.
      var error: NSError?
      let existingEntity = context.existingObjectWithID(self.id!, error: &error)
      if existingEntity != nil && error == nil {
        return existingEntity!
      } else if error != nil {
        NSLog("%@", error!)
      }
    }
    let entity = NSEntityDescription.entityForName("DailyTask", inManagedObjectContext: context)
    let managedEntity = DailyTaskEntity(entity: entity!, insertIntoManagedObjectContext: context) as DailyTaskEntity
    managedEntity.details = details
    managedEntity.shortTitle = shortTitle
    managedEntity.forPeriod = period
    managedEntity.dateDue = date
    managedEntity.isCompleted = isCompleted
    managedEntity.isHaikuAssignment = isHaikuAssignment
    managedEntity.priority = priority.rawValue
    return managedEntity as NSManagedObject
  }
}

struct TaskSummary {
  let title: String
  let completion: Bool
  let remainingTasks: Int
  static let DefaultSummary: TaskSummary = TaskSummary(title: "", completion: false, remainingTasks: 0)
}

class DailyTaskEntity: NSManagedObject {
  @NSManaged var forPeriod: NSNumber
  @NSManaged var dateDue: NSDate
  @NSManaged var shortTitle: String
  @NSManaged var details: String
  @NSManaged var isHaikuAssignment: NSNumber
  @NSManaged var isCompleted: NSNumber
  @NSManaged var priority: NSNumber

}

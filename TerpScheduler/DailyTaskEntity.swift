//
//  DailyTask.swift
//  TerpScheduler
//
//  Created by Ben Hall on 12/18/14.
//  Copyright (c) 2014 Tampa Preparatory School. All rights reserved.
//

import Foundation
import CoreData

func == (lhs: DailyTask, rhs: DailyTask) -> Bool {
  let isTitleSame = lhs.shortTitle == rhs.shortTitle
  let isDetailsSame = lhs.details == rhs.details
  let isPrioritySame = lhs.priority == rhs.priority
  let isCompletionStatusSame = lhs.isCompleted == rhs.isCompleted
  let isHaikuStatusSame = lhs.isHaikuAssignment == rhs.isHaikuAssignment
  let isNotificationStatusSame = lhs.shouldNotify == rhs.shouldNotify
  return isTitleSame && isDetailsSame && isPrioritySame && isCompletionStatusSame && isHaikuStatusSame && isNotificationStatusSame
}

enum Priorities: Int {
  case highest = 0
  case high = 1
  case medium = 2
  case low = 3
  case lowest = 4
  case completed = 5
}

class DailyTask: Filterable, Equatable, DataObject {
  var id: NSManagedObjectID?
    var GUID: String?
  let date: Date
  let period: Int
  var shortTitle: String
  var details: String
  var isHaikuAssignment: Bool
  var isCompleted: Bool
  var priority: Priorities
  var shouldNotify: Bool

    /// Data object for each task as entered.
    ///
    /// This is the core entity in the app. All user data is stored ultimately in DailyTasks.
    /// - Parameters:
    ///   - date: The date for which the task was entered. The tasks are displayed based on this date.
    ///   - period: The class period (1-8) to which the task is related.
    ///   - shortTitle: The title to be displayed for the task. Cannot be empty
    ///   - details: Long-form details if entered. May be empty.
    ///   - isHaiku: True if the task should be turned in on PSL/Haiku.
    ///   - completion: True if the task is already marked as completed.
    ///   - priority: The  priority level of tasks, used for sorting.
    ///   - notify: Should the user be notified of this task
    ///   - guid: A system-assigned GUID.
    init(date: Date, period: Int, shortTitle: String, details: String, isHaiku: Bool, completion: Bool, priority: Priorities, notify: Bool, guid: String?) {
    self.date = date
    self.period = period
    self.shortTitle = shortTitle
    self.details = details
    self.isCompleted = completion
    self.isHaikuAssignment = isHaiku
    self.priority = priority
    self.shouldNotify = notify
        self.GUID = guid
  }
    
    required init(entity: NSManagedObject) {
        guard let model = entity as? DailyTaskEntity else {
            //if this happens, the whole thing is borked
            abort()
        }
        let context = model.managedObjectContext!
        do {
            try context.save()
        } catch _ {
        }
        
        id = model.objectID
        date = model.dateDue
        shortTitle = model.shortTitle
        details = model.details
        isHaikuAssignment = Bool(truncating: model.isHaikuAssignment)
        isCompleted = Bool(truncating: model.isCompleted)
        priority = Priorities(rawValue: Int(truncating: model.priority))!
        period = Int(truncating: model.forPeriod)
        shouldNotify = model.hasNotification
        GUID = model.guid
        if GUID == nil {
            print("uh oh")
        }
    }
    
    ///creates managed entity associated with this data in the provided context.
    ///Only creates new if no entity with this id already exists.
    ///
    /// Parameter inContext: The NSManagedObjectContext to put the entity in.
    /// Returns: A NSManagedObject containing the data from self.
    func toEntity(inContext context: NSManagedObjectContext, isNew: Bool) -> NSManagedObject {
        if self.id != nil {
            // If a entity with this id already exists, return it.
            var error: NSError?
            let existingEntity: NSManagedObject?
            do {
                existingEntity = try context.existingObject(with: self.id!)
            } catch let error1 as NSError {
                error = error1
                existingEntity = nil
            }
            if existingEntity != nil && error == nil {
                return existingEntity!
            } else if error != nil {
                NSLog("%@", error!)
            }
        }
        let entity = NSEntityDescription.entity(forEntityName: "DailyTask", in: context)
        let managedEntity = DailyTaskEntity(entity: entity!, insertInto: context) as DailyTaskEntity
        managedEntity.details = details
        managedEntity.shortTitle = shortTitle
        managedEntity.forPeriod = NSNumber(value: period)
        managedEntity.dateDue = date
        managedEntity.isCompleted = isCompleted as NSNumber
        managedEntity.isHaikuAssignment = isHaikuAssignment as NSNumber
        managedEntity.priority = NSNumber(value: priority.rawValue)
        managedEntity.hasNotification = shouldNotify
        if isNew {
            managedEntity.guid = UUID().uuidString
        } else {
            managedEntity.guid = GUID
        }
        
        return managedEntity as NSManagedObject
    }
}

extension DailyTask {
  /// Compares dates of assignments, returns true if this task is before the previous one.
  ///
  /// - Parameter other: The other DailyTask to which to compare.
  /// - Returns: True if before, False if after.
  func dateIsBefore(_ other: DailyTask) -> Bool {
    return (date.compare(other.date) == ComparisonResult.orderedAscending)
  }

  /// Compares the school class periods assigned to this DailyTask and another.
  ///
  /// - Parameter other: The other DailyTask to which to compare.
  /// - Returns: True if before, False if after.
  func periodIsBefore(_ other: DailyTask) -> Bool {
    return period < other.period
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
  @NSManaged var dateDue: Date
  @NSManaged var shortTitle: String
  @NSManaged var details: String
  @NSManaged var isHaikuAssignment: NSNumber
  @NSManaged var isCompleted: NSNumber
  @NSManaged var priority: NSNumber
  @NSManaged var hasNotification: Bool
    @NSManaged var guid: String?
    
    /// Updates the data that can change from a new DailyTask entity (for storage).
    ///
    /// - Parameter taskData: The DailyTask containing the new data.
    func update(taskData: DailyTask) {
        self.shortTitle = taskData.shortTitle
        self.details = taskData.details
        self.isCompleted = taskData.isCompleted as NSNumber
        self.isHaikuAssignment = taskData.isHaikuAssignment as NSNumber
        self.priority = taskData.priority.rawValue as NSNumber
        self.hasNotification = taskData.shouldNotify
    }

}

//
//  TaskCollectionRepository.swift
//  TerpScheduler
//
//  Created by Ben Hall on 1/12/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import UIKit
import CoreData

struct TaskSummaryData {
    let shortTitle : String
    let remainingTasks : Int
    let priority : Priorities
}

class TaskCollectionRepository: NSObject {
  let context : NSManagedObjectContext
  
  init(context: NSManagedObjectContext){
    self.context = context
  }
  
  func taskSummariesForDates(startDate: NSDate, stopDate : NSDate) -> [TaskSummaryData]{
    var answer : [TaskSummaryData] = []
    for period in 1...7{
      var currentDate = startDate
      while (currentDate.compare(stopDate) == NSComparisonResult.OrderedAscending ||
        currentDate.compare(stopDate) == NSComparisonResult.OrderedSame){
          if let summary = taskSummariesForDateAndPeriod(startDate, period: period){
            answer.append(summary)
          }
          currentDate = NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.CalendarUnitDay, value: 1, toDate: currentDate, options: NSCalendarOptions.allZeros)!
      }
    }
    return answer
  }
  
  func taskSummariesForDateAndPeriod(date: NSDate, period: Int) -> TaskSummaryData?{
    var answer : TaskSummaryData?
    if let result = fetchEntity("TaskSummary", withDate: date, andPeriod: period) as? [TaskSummaryModel]{
      if result.count == 0{
        answer = TaskSummaryData(shortTitle: "No Tasks!", remainingTasks: 0, priority: Priorities.Completed)
      }
      else {
        let model = result[0]
        let shortTitle = model.shortTitle
        let remaining = Int(model.remainingTasks)
        let priority = Priorities(rawValue: Int(model.priority))
        answer = TaskSummaryData(shortTitle: shortTitle, remainingTasks: remaining, priority: priority!)
      }
    } else {
      answer = nil
    }
    return answer
  }
  
  func tasksForDateAndPeriod(date: NSDate, period: Int) -> [DailyTaskData]{
    var answer: [DailyTaskData] = []
    if let results = fetchEntity("DailyTask", withDate: date, andPeriod: period) as? [DailyTask]{
      if results.count != 0 {
        for task in results {
          answer.append(DailyTaskData(model: task))
        }
      }
    }
    return answer
  }
  
  func fetchEntity(entity: String, withDate date: NSDate, andPeriod period: Int, optionalPredicate pred:NSPredicate? = nil)->[AnyObject]?{
    let fetchRequest = NSFetchRequest(entityName: entity)
    let sortByPriority = NSSortDescriptor(key: "priority", ascending: true)
    fetchRequest.sortDescriptors = [sortByPriority]
    let datePredicate = NSPredicate(format: "dateDue = %@", date)
    let periodPredicate = NSPredicate(format: "forPeriod = %i", period)
    if pred != nil {
      fetchRequest.predicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [datePredicate!, periodPredicate!, pred!])
    } else {
      fetchRequest.predicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [datePredicate!, periodPredicate!])
    }
    var error: NSError?
    let answer = context.executeFetchRequest(fetchRequest, error: &error)
    return error == nil ? answer : nil
  }
  
  func modelFromData(data: DailyTaskData, forPeriod period: Int){
    var model: DailyTask?
    func newModel()->DailyTask?{
      let entity = NSEntityDescription.entityForName("DailyTask", inManagedObjectContext: context)
      let newModel = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: context) as? DailyTask
      return newModel
    }
    let optionalPredicate = NSPredicate(format: "id = %@", data.id)
    if let results = fetchEntity("DailyTask", withDate: data.due, andPeriod: period, optionalPredicate: optionalPredicate){
      if results.count > 0 {
        model = results[0] as? DailyTask
      } else {
        model = newModel()
      }
    } else {
      model = newModel()
    }
    model!.id = data.id
    model!.dateDue = data.due
    model!.isCompleted = NSNumber(bool: data.isCompleted)
    model!.isHaikuAssignment = NSNumber(bool: data.isHaikuAssignment)
    model!.shortTitle = data.shortTitle
    model!.details = data.details
    context.save(nil)
  }

    
}

//
//  TaskRepository.swift
//  TerpScheduler
//
//  Created by Ben Hall on 1/21/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import Foundation
import CoreData

class TaskRepository {
  init(context: NSManagedObjectContext){
    repository = Repository<DailyTask, DailyTaskEntity>(entityName: "DailyTask", withContext: context)
    entity = NSEntityDescription.entityForName("DailyTask", inManagedObjectContext: context)!
    self.context = context
    defaultTask = fetchOrLoadDefaultTask()
  }
  
  private let repository: Repository<DailyTask, DailyTaskEntity>
  private let entity: NSEntityDescription
  private let context: NSManagedObjectContext
  private let summaryFilterType = RepositoryFilterType.byDateBetween
  private let taskListFilterType = RepositoryFilterType.byDateAndPeriod
  private let taskDetailFilterType = RepositoryFilterType.byID
  private var summaries: [TaskSummary] = []
  
  private func fetchOrLoadDefaultTask()->DailyTask{
    let fetchRequest = NSFetchRequest(entityName: "DailyTask")
    fetchRequest.predicate = NSPredicate(format: "forPeriod = %i", -1)
    let results = context.executeFetchRequest(fetchRequest, error: nil) as! [DailyTaskEntity]
    if results.count == 0 {
      //the default task isn't created yet, so add it and return it
      let entityDescription = NSEntityDescription.entityForName("DailyTask", inManagedObjectContext: context)
      let task = DailyTaskEntity(entity: entityDescription!, insertIntoManagedObjectContext: context)
      task.shortTitle = ""
      task.forPeriod = -1
      task.details = ""
      task.dateDue = NSDate()
      var error: NSError?
      context.save(&error)
      if error != nil {
        NSLog("%@", error!)
      }
      return DailyTask(entity: task)
    } else {
      //default task is already there, so just return it
      return DailyTask(entity: results[0])
    }
  }
  
  var defaultTask: DailyTask?
  
  ///Saves data to backing store. If given a non-nil withMergeFromTask, overwrite the old task with the new data.
  ///
  ///:param: data New data to be saved
  ///:param: withMergeFromTask Old data to overwrite. Nil implies it's a new task.
  func persistData(data: DailyTask, withMergeFromTask oldTask: DailyTask?){
    if oldTask != nil {
      let newTask = DailyTask(date: oldTask!.date, period: oldTask!.period, shortTitle: data.shortTitle, details: data.details, isHaiku: data.isHaikuAssignment, completion: data.isCompleted, priority: data.priority, notify: false)
      repository.add(newTask)
      repository.deleteItemMatching(values: oldTask!)
    } else {
      repository.add(data)
    }
  }
  
  ///Fetches all tasks associated with both given date and period (1 indexed).
  ///
  ///:param: date The NSDate for which to fetch tasks. Time portions ignored.
  ///:param: period 1-indexed integer for the class period.
  ///:returns: A list of DailyTasks, sorted by priority
  func tasksForDateAndPeriod(date: NSDate, period: Int)->[DailyTask]{
    let tasks = repository.fetchBy(taskListFilterType, values: FilterValues(optDate: date, optID: nil, optPeriod: period, optTitle: nil))
    let sortedTasks = sorted(tasks, {$0.priority.rawValue < $1.priority.rawValue})
    return sortedTasks
  }
  
  
  ///Fetches all task summaries for dates between inputs (inclusive).
  ///
  ///:param: startDate First date to fetch summaries for
  ///:param: stopDate: Last date to fetch summaries for
  ///:returns: A list of TaskSummary objects sorted by period->date->priority
  func taskSummariesForDatesBetween(startDate: NSDate, stopDate: NSDate)->[TaskSummary]{
    var summaries: [TaskSummary] = []
    let dates = dateRange(startDate, stopDate)
    for period in 1...8{
      for date in dates {
        let tasks = tasksForDateAndPeriod(date, period: period)
        if tasks.count > 0 {
          //NSLog("Found a task for period %d", period)
          let topTask = tasks[0]
          summaries.append(TaskSummary(title: topTask.shortTitle, completion: topTask.isCompleted, remainingTasks: tasks.count - 1))
        } else {
          summaries.append(TaskSummary.DefaultSummary)
        }
      }
    }
    return summaries
  }
  
  func taskDetailForID(id: NSManagedObjectID)->DailyTask?{
    if let result = context.existingObjectWithID(id, error: nil) {
      return DailyTask(entity: result)
    }
    return nil
  }
  
  func deleteItem(item: DailyTask){
    repository.deleteItemMatching(values: item)
  }

  func allTasksForPeriod(period: Int)->[DailyTask]{
    let filter = FilterValues(optDate: nil, optID: nil, optPeriod: period, optTitle: nil)
    let tasks = repository.fetchBy(.byPeriod, values: filter)
    return tasks
  }
  
  func allTasksForDate(date: NSDate)->[DailyTask]{
    let filter = FilterValues(optDate: date, optID: nil, optPeriod: nil, optTitle: nil)
    let tasks = repository.fetchBy(.byDate, values: filter)
    return tasks
  }
  
  func allTasks()->[DailyTask]{
    return repository.fetchAll()
  }
  
}
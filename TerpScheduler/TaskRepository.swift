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
  init(context: NSManagedObjectContext) {
    repository = Repository<DailyTask, DailyTaskEntity>(entityName: "DailyTask", withContext: context)
    entity = NSEntityDescription.entity(forEntityName: "DailyTask", in: context)!
    self.context = context
    defaultTask = fetchOrLoadDefaultTask()
  }

  fileprivate let repository: Repository<DailyTask, DailyTaskEntity>
  fileprivate let entity: NSEntityDescription
  fileprivate let context: NSManagedObjectContext
  fileprivate let summaryFilterType = RepositoryFilterType.byDateBetween
  fileprivate let taskListFilterType = RepositoryFilterType.byDateAndPeriod
  fileprivate let taskDetailFilterType = RepositoryFilterType.byID
  fileprivate var summaries: [TaskSummary] = []

  fileprivate func fetchOrLoadDefaultTask() -> DailyTask {
    let fetchRequest: NSFetchRequest<DailyTaskEntity> = NSFetchRequest(entityName: "DailyTask")
    fetchRequest.predicate = NSPredicate(format: "forPeriod = %i", -1)
    let results = try? context.fetch(fetchRequest)
    if results!.count == 0 {
      //the default task isn't created yet, so add it and return it
      let entityDescription = NSEntityDescription.entity(forEntityName: "DailyTask", in: context)
      let task = DailyTaskEntity(entity: entityDescription!, insertInto: context)
      task.shortTitle = ""
      task.forPeriod = -1
      task.details = ""
      task.dateDue = Date()
      var error: NSError?
      do {
        try context.save()
      } catch let error1 as NSError {
        error = error1
      }
      if error != nil {
        NSLog("%@", error!)
      }
      return DailyTask(entity: task)
    } else {
      //default task is already there, so just return it
      return DailyTask(entity: results![0])
    }
  }

  var defaultTask: DailyTask?
  ///Saves data to backing store. If given a non-nil withMergeFromTask, overwrite the old task with the new data.
  ///
  ///- parameter data: New data to be saved
  ///- parameter withMergeFromTask: Old data to overwrite. Nil implies it's a new task.
  func persistData(_ data: DailyTask, withMergeFromTask oldTask: DailyTask?) {
    if oldTask != nil {
      let newTask = DailyTask(date: oldTask!.date, period: oldTask!.period, shortTitle: data.shortTitle, details: data.details, isHaiku: data.isHaikuAssignment, completion: data.isCompleted, priority: data.priority, notify: data.shouldNotify)
      repository.add(newTask)
      repository.deleteItemMatching(values: oldTask!)
    } else {
      repository.add(data)
    }
  }

  ///Fetches all tasks associated with both given date and period (1 indexed).
  ///
  ///- parameter date: The NSDate for which to fetch tasks. Time portions ignored.
  ///- parameter period: 1-indexed integer for the class period.
  ///- returns: A list of DailyTasks, sorted by priority
  func tasksForDateAndPeriod(_ date: Date, period: Int) -> [DailyTask] {
    let tasks = repository.fetchBy(taskListFilterType, values: FilterValues(optDate: date, optID: nil, optPeriod: period, optTitle: nil))
    let sortedTasks = tasks.sorted(by: {$0.priority.rawValue < $1.priority.rawValue})
    return sortedTasks
  }

  ///Fetches all task summaries for dates between inputs (inclusive).
  ///
  ///- parameter startDate: First date to fetch summaries for
  ///- parameter stopDate:: Last date to fetch summaries for
  ///- returns: A list of TaskSummary objects sorted by period->date->priority
  func taskSummariesForDatesBetween(_ startDate: Date, stopDate: Date) -> [TaskSummary] {
    var summaries: [TaskSummary] = []
    let dates = dateRange(startDate, stop: stopDate)
    for period in 1...8 {
      for date in dates {
        let tasks = tasksForDateAndPeriod(date, period: period)
        if tasks.count > 0 {
          let topTask = tasks[0]
          summaries.append(TaskSummary(title: topTask.shortTitle, completion: topTask.isCompleted, remainingTasks: tasks.count - 1))
        } else {
          summaries.append(TaskSummary.DefaultSummary)
        }
      }
    }
    return summaries
  }

  func taskDetailForID(_ id: NSManagedObjectID) -> DailyTask? {
    if let result = try? context.existingObject(with: id) {
      return DailyTask(entity: result)
    }
    return nil
  }

  func deleteItem(_ item: DailyTask) {
    repository.deleteItemMatching(values: item)
  }

  func allTasksForPeriod(_ period: Int) -> [DailyTask] {
    let filter = FilterValues(optDate: nil, optID: nil, optPeriod: period, optTitle: nil)
    let tasks = repository.fetchBy(.byPeriod, values: filter)
    return tasks
  }

  func allTasksForDate(_ date: Date) -> [DailyTask] {
    let filter = FilterValues(optDate: date, optID: nil, optPeriod: nil, optTitle: nil)
    let tasks = repository.fetchBy(.byDate, values: filter)
    return tasks
  }

  func allTasks() -> [DailyTask] {
    return repository.fetchAll()
  }

  func countAllTasks() -> Int {
    let fetchRequest: NSFetchRequest<DailyTaskEntity> = NSFetchRequest(entityName: "DailyTask")
    fetchRequest.predicate = NSPredicate(value: true)
    var output = 0
    do {
      try output = context.count(for: fetchRequest)
    } catch (_) {
      //intentionally left blank
    }
    return output
  }

  func persistTasks(_ tasks: [DailyTask]) {
    for task in tasks {
      repository.addWithoutSave(task)
    }
    repository.save()
  }
}

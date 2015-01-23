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
    fetchRequest.predicate = NSPredicate(format: "period = %i", 0)
    let results = context.executeFetchRequest(fetchRequest, error: nil) as [DailyTaskEntity]
    if results.count == 0 {
      let entityDescription = NSEntityDescription.entityForName("DailyTask", inManagedObjectContext: context)
      let task = DailyTaskEntity(entity: entityDescription!, insertIntoManagedObjectContext: context)
      task.shortTitle = ""
      task.forPeriod = 0
      task.details = ""
      context.save(nil)
      return DailyTask(entity: task)
    } else {
      return DailyTask(entity: results[0])
    }
  }
  
  
  var defaultTask: DailyTask?
  
  func persistData(data: DailyTask){
    if let matchingTask = taskDetailForID(data.id) {
      deleteItem(data) //only store the updated object
    }
    let entity = data.toEntity(inContext: context)
    repository.add(data, entity: entity as DailyTaskEntity)
  }
  
  func tasksForDateAndPeriod(date: NSDate, period: Int)->[DailyTask]{
    let tasks = repository.fetchBy(taskListFilterType, values: FilterValues(optDate: date, optID: nil, optPeriod: period, optTitle: nil))
    let sortedTasks = sorted(tasks, {$0.priority.rawValue < $1.priority.rawValue})
    return sortedTasks
  }
  
  func taskSummariesForDatesBetween(startDate: NSDate, stopDate: NSDate)->[TaskSummary]{
    var summaries: [TaskSummary] = []
    let dates = dateRange(startDate, stopDate)
    for period in 1...7{
      for date in dates {
        let tasks = tasksForDateAndPeriod(date, period: period)
        if tasks.count > 0 {
          let topTask = tasks[0]
          summaries.append(TaskSummary(title: topTask.shortTitle, remainingTasks: tasks.count - 1))
        } else {
          summaries.append(TaskSummary.DefaultSummary)
        }
      }
    }
    return summaries
  }
  
  func taskDetailForID(id: NSManagedObjectID)->DailyTask?{
    let tasks = repository.fetchBy(taskDetailFilterType, values: FilterValues(optDate: nil, optID: id, optPeriod: nil, optTitle: nil))
    if tasks.count > 0 {
      return tasks[0]
    } else {
      return nil
    }
  }
  
  func deleteItem(item: DailyTask){
    repository.deleteItemMatching(values: item)
  }

  
  
}
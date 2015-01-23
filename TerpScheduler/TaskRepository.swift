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
    repository = Repository<DailyTask>(entityName: "DailyTask", withContext: context)
    entity = NSEntityDescription.entityForName("DailyTask", inManagedObjectContext: context)!
    self.context = context
    let idForDefaultTask = NSUUID(UUIDString: "68753A44-4D6F-1226-9C60-0050E4C00067")!
    var defaultTaskData = taskDetailForID(idForDefaultTask)
    if defaultTaskData == nil {
      defaultTask = DailyTask(id: idForDefaultTask, date: NSDate(), period: 0, shortTitle: "", details: "", isHaikuAssignment: false, isCompleted: false, priority: Priorities.Medium)
      persistData(defaultTask!)
    } else {
      defaultTask = defaultTaskData!
    }
  }
  
  private let repository: Repository<DailyTask>
  private let entity: NSEntityDescription
  private let context: NSManagedObjectContext
  private let summaryFilterType = RepositoryFilterType.byDateBetween
  private let taskListFilterType = RepositoryFilterType.byDateAndPeriod
  private let taskDetailFilterType = RepositoryFilterType.byID
  private var summaries: [TaskSummary] = []
  
  var defaultTask: DailyTask?
  
  func persistData(data: DailyTask){
    let entity = data.toEntity(inContext: context)
    repository.add(data, entity: entity)
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
  
  func taskDetailForID(id: NSUUID)->DailyTask?{
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
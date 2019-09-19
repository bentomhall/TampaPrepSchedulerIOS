//
//  TaskRepository.swift
//  TerpScheduler
//
//  Created by Ben Hall on 1/21/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import Foundation
import CoreData

/// Handles storing and loading `DailyTask`s to the item store. Use this, not a bare `Repository<DailyTask>`.
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
            task.guid = UUID().uuidString
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
    ///- Parameter data: New data to be saved
    ///- Parameter withMergeFromTask: Old data to overwrite. Nil implies it's a new task.
    func persistData(_ data: DailyTask, withMergeFromTask oldTask: DailyTask?) -> DailyTask {
        if oldTask != nil {
            if oldTask!.GUID != nil {
                if let task = repository.fetchForUpdate(byGUID: oldTask!.GUID) {
                    task.update(taskData: data)
                    repository.save()
                }
                
            }
            else {
                //shouldn't hit here, but...
                repository.add(data)
            }
        } else {
            
            repository.add(data)
            
        }
        return data
    }
    
    ///Fetches all tasks associated with both given date and period (1 indexed).
    ///
    ///- Parameter date: The NSDate for which to fetch tasks. Time portions ignored.
    ///- Parameter period: 1-indexed integer for the class period.
    ///- Returns: A list of DailyTasks, sorted by priority
    func tasksForDateAndPeriod(_ date: Date, period: Int) -> [DailyTask] {
        let tasks = repository.fetchBy(taskListFilterType, values: FilterValues(optDate: date, optID: nil, optPeriod: period, optTitle: nil, optGUID: nil))
        let sortedTasks = tasks.sorted(by: {$0.priority.rawValue < $1.priority.rawValue})
        return sortedTasks
    }
    
    ///Fetches all task summaries for dates between inputs (inclusive).
    ///
    ///- Parameter startDate: First date to fetch summaries for
    ///- Parameter stopDate:: Last date to fetch summaries for
    ///- Returns: A list of TaskSummary objects sorted by period->date->priority
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
    
    /// Retrieves all the data for a given `NSManagedObjectID`.
    ///
    /// - Parameter id: The id for the element to be retrieved.
    /// - Returns: The data for the provided ID.
    func taskDetailForID(_ id: NSManagedObjectID) -> DailyTask? {
        if let result = try? context.existingObject(with: id) {
            return DailyTask(entity: result)
        }
        return nil
    }
    
    /// Wrapper to delete `DailyTask` item.
    ///
    /// - Parameter item: The item to delete.
    func deleteItem(_ item: DailyTask) {
        repository.deleteItemMatching(values: item)
    }
    
    /// Count all tasks
    ///
    /// - Returns: A total number of stored `DailyTask` entries.
    @available(*,deprecated, message: "Unused")
    func countAllTasks() -> Int {
        let fetchRequest: NSFetchRequest<DailyTaskEntity> = NSFetchRequest(entityName: "DailyTask")
        fetchRequest.predicate = NSPredicate(value: true)
        let output = try? context.count(for: fetchRequest)
        return output ?? 0
    }
    
    /// Save a list of `DailyTask` entities in bulk.
    ///
    /// - Parameter tasks: The tasks to be saved.
    func persistTasks(_ tasks: [DailyTask]) {
        for task in tasks {
            repository.addWithoutSave(task)
        }
        repository.save()
    }
}

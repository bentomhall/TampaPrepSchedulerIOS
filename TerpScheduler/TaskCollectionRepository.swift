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
        var currentDate = startDate
        for period in 1...7{
            while (currentDate.compare(stopDate) == NSComparisonResult.OrderedAscending ){
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
        var error : NSError?
        var fetchRequest = NSFetchRequest(entityName: "TaskSummary")
        let sortByPriority = NSSortDescriptor(key: "priority", ascending: true)
        fetchRequest.sortDescriptors = [sortByPriority]
        let datePredicate = NSPredicate(format: "dateDue = %@", date)
        let periodPredicate = NSPredicate(format: "forPeriod = %i", period)
        fetchRequest.predicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [datePredicate!, periodPredicate!])
        if let result = context.executeFetchRequest(fetchRequest, error: &error) as? [TaskSummaryModel]{
            if error != nil {
                NSLog("Error was: %@", error!)
            }
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
    
}

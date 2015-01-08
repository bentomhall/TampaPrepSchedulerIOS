//
//  DailyTasksData.swift
//  TerpScheduler
//
//  Created by Ben Hall on 1/7/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import UIKit
import CoreData

class DailyTasksForPeriod {
    var Tasks : [DailyTask] = []
    
    var RemainingTasksCount : Int {
        get { return (Tasks.count > 0 ? Tasks.count - 1 : 0)}
    }
    
    init(forPeriod: Int, forDay: String, fromContext: NSManagedObjectContext){
        let fetchRequest = NSFetchRequest(entityName: "DailyTask")
        
        let datePredicate = NSPredicate(format: "due = %s", forDay)
        let periodPredicate = NSPredicate(format: "classPeriod = %i", forPeriod)
        let combinedPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [datePredicate!, periodPredicate!])
        fetchRequest.predicate = combinedPredicate
        
        let sortDescriptors = NSSortDescriptor(key: "priority", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptors]
        
        if let fetchResults = fromContext.executeFetchRequest(fetchRequest, error: nil){
            Tasks = fetchResults as [DailyTask]
        }
    }
    
    func GetHighestPriorityTaskTitle()->String{
        let title = Tasks.count > 0 ? Tasks[0].shortTitle : ""
        return title
    }
}

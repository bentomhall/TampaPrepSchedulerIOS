//
//  DailyTasksCollection.swift
//  TerpScheduler
//
//  Created by Ben Hall on 1/7/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import UIKit
import CoreData

class DailyTasksCollection: NSObject {
    var tasksForAllPeriods : [DailyTasksForPeriod] = []
    let periods = 7
    
    init(dateString:String, withContext: NSManagedObjectContext){
        for index in 1...periods {
            let taskModel = DailyTasksForPeriod(forPeriod: index, forDay: dateString, fromContext: withContext)
            tasksForAllPeriods.append(taskModel)
        }
    }
}

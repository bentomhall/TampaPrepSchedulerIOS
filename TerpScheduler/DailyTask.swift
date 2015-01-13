//
//  DailyTask.swift
//  TerpScheduler
//
//  Created by Ben Hall on 12/18/14.
//  Copyright (c) 2014 Tampa Preparatory School. All rights reserved.
//

import Foundation
import CoreData

enum Priorities: Int {
    case Highest = 0
    case High = 1
    case Medium = 2
    case Low = 3
    case Lowest = 4
    case Completed = 5
}

struct DailyTaskData {
    let due : NSDate
    let shortTitle : String
    let details : String
    let isHaikuAssignment : Bool
    let isCompleted : Bool
    let priority : Priorities
}

class DailyTask: NSManagedObject {

    @NSManaged var due: String
    @NSManaged var classPeriod: NSNumber
    @NSManaged var shortTitle: String
    @NSManaged var details: String
    @NSManaged var isHaikuAssignment: NSNumber
    @NSManaged var isCompleted: NSNumber
    @NSManaged var priority: NSNumber

}

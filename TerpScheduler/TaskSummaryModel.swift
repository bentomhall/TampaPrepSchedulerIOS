//
//  TaskSummaryModel.swift
//  TerpScheduler
//
//  Created by Ben Hall on 1/13/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import UIKit
import CoreData

class TaskSummaryModel: NSManagedObject {
    @NSManaged var dateDue : NSDate
    @NSManaged var forPeriod : NSNumber
    @NSManaged var remainingTasks : NSNumber
    @NSManaged var shortTitle: String
    @NSManaged var priority: NSNumber
}

//
//  DailyTask.swift
//  TerpScheduler
//
//  Created by Ben Hall on 12/18/14.
//  Copyright (c) 2014 Tampa Preparatory School. All rights reserved.
//

import Foundation
import CoreData

class DailyTask: NSManagedObject {

    @NSManaged var due: NSDate
    @NSManaged var classPeriod: NSNumber
    @NSManaged var shortTitle: String
    @NSManaged var details: String
    @NSManaged var isHaikuAssignment: NSNumber
    @NSManaged var isCompleted: NSNumber

}

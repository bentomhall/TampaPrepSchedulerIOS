//
//  WeekModel.swift
//  TerpScheduler
//
//  Created by Ben Hall on 1/5/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import Foundation
import CoreData

class WeekModel : NSManagedObject{
    @NSManaged var FirstWeekDay : NSDate
    @NSManaged var WeekID: Int
    @NSManaged var WeekSchedule: String
    
    func ParseWeekSchedule()->[String]{
        return WeekSchedule.componentsSeparatedByString(" ")
    }
    
    
}

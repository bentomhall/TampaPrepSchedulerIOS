//
//  SchoolClassesModel.swift
//  TerpScheduler
//
//  Created by Ben Hall on 1/5/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import Foundation
import CoreData

class SchoolClassesModel: NSManagedObject {
    @NSManaged var classPeriod : Int
    @NSManaged var teacherName : String
    @NSManaged var haikuURL : String
    @NSManaged var isStudyHall : Bool
    @NSManaged var subject: String
    
}

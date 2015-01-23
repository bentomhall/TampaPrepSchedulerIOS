//
//  SchoolClassesModel.swift
//  TerpScheduler
//
//  Created by Ben Hall on 1/5/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import Foundation
import CoreData

struct SchoolClass {
  let period: Int
  let teacherName: String
  let haikuURL: NSURL?
  let isStudyHall: Bool
  let subject: String
  
  static func DefaultForPeriod(period: Int)->SchoolClass{
    return SchoolClass(period: period, teacherName: "No Teacher Selected", haikuURL: nil, isStudyHall: false, subject: "No Subject Selected")
  }
}

extension SchoolClass: DataObject{
  init(entity: NSManagedObject){
    let entity = entity as SchoolClassesEntity
    period = entity.classPeriod
    teacherName = entity.teacherName
    if entity.haikuURL != ""{
      haikuURL = NSURL(string: entity.haikuURL)
    }
    isStudyHall = entity.isStudyHall
    subject = entity.subject
  }
  
  func toEntity(inContext context: NSManagedObjectContext) -> NSManagedObject {
    let entity = NSEntityDescription.entityForName("SchoolClasses", inManagedObjectContext: context)
    let managedObject = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: context) as SchoolClassesEntity
    managedObject.classPeriod = period
    managedObject.teacherName = teacherName
    managedObject.haikuURL = haikuURL != nil ? haikuURL!.absoluteString! : ""
    managedObject.isStudyHall = isStudyHall
    managedObject.subject = subject
    return managedObject
  }
}

class SchoolClassesEntity: NSManagedObject {
    @NSManaged var classPeriod : Int
    @NSManaged var teacherName : String
    @NSManaged var haikuURL : String
    @NSManaged var isStudyHall : Bool
    @NSManaged var subject: String
}

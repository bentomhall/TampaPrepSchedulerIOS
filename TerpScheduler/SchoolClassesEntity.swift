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
  let isLocked: Bool
  let id: NSManagedObjectID?
  
  static func DefaultForPeriod(period: Int)->SchoolClass{
    return SchoolClass(period: period, teacherName: "No Teacher Selected", haikuURL: nil, isStudyHall: false, subject: "No Subject Selected", isLocked: false, id: nil)
  }
}

extension SchoolClass: DataObject{
  init(entity: NSManagedObject){
    let entity = entity as SchoolClassesEntity
    period = entity.classPeriod.integerValue
    teacherName = entity.teacherName
    if entity.haikuURL != ""{
      haikuURL = NSURL(string: entity.haikuURL)
    }
    isStudyHall = entity.isStudyHall
    subject = entity.subject
    isLocked = entity.isLocked
    id = entity.objectID
  }
  
  func toEntity(inContext context: NSManagedObjectContext) -> NSManagedObject {
    var managedObject: SchoolClassesEntity?
    var alreadyExists = false
    if self.id != nil {
      var error: NSError?
      let existingEntity = context.existingObjectWithID(self.id!, error: &error)
      if existingEntity != nil && error == nil {
        managedObject = (existingEntity! as SchoolClassesEntity)
        alreadyExists = true
      } else if error != nil {
        NSLog("%@", error!)
      }
    }
    if !alreadyExists{
      let entity = NSEntityDescription.entityForName("SchoolClasses", inManagedObjectContext: context)
      managedObject = (NSManagedObject(entity: entity!, insertIntoManagedObjectContext: context) as SchoolClassesEntity)
    }
    managedObject!.classPeriod = period
    managedObject!.teacherName = teacherName
    managedObject!.haikuURL = haikuURL != nil ? haikuURL!.absoluteString! : ""
    managedObject!.isStudyHall = isStudyHall
    managedObject!.subject = subject
    managedObject!.isLocked = isLocked
    return managedObject!
  }
}

class SchoolClassesEntity: NSManagedObject {
  @NSManaged var classPeriod : NSNumber
  @NSManaged var teacherName : String
  @NSManaged var haikuURL : String
  @NSManaged var isStudyHall : Bool
  @NSManaged var subject: String
  @NSManaged var isLocked: Bool
}

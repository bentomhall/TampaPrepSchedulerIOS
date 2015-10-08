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
  
  static func defaultForPeriod(period: Int)->SchoolClass{
    //sometimes there's a disconnect and a 0-indexed period gets passed in. Sigh. Hack.
    return SchoolClass(period: period+1, teacherName: "", haikuURL: nil, isStudyHall: false, subject: "", isLocked: false, id: nil)
  }
  
  static func middleSchoolSports()->SchoolClass{
    return SchoolClass(period: 7, teacherName: "", haikuURL: nil, isStudyHall: false, subject: "Sports", isLocked: true, id: nil)
  }
}

extension SchoolClass: DataObject{
  init(entity: NSManagedObject){
    let entity = entity as! SchoolClassesEntity
    period = entity.classPeriod.integerValue
    teacherName = entity.teacherName
    if entity.haikuURL != ""{
      haikuURL = NSURL(string: entity.haikuURL)
    } else {
      haikuURL = nil
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
      let existingEntity: NSManagedObject?
      do {
        existingEntity = try context.existingObjectWithID(self.id!)
      } catch let error as NSError {
        existingEntity = nil
        NSLog("%@", error)
      }
      if existingEntity != nil {
        managedObject = (existingEntity! as! SchoolClassesEntity)
        alreadyExists = true
      }
    }
    if !alreadyExists{
      let entity = NSEntityDescription.entityForName("SchoolClasses", inManagedObjectContext: context)
      managedObject = (NSManagedObject(entity: entity!, insertIntoManagedObjectContext: context) as! SchoolClassesEntity)
    }
    managedObject!.classPeriod = period
    managedObject!.teacherName = teacherName
    managedObject!.haikuURL = haikuURL != nil ? haikuURL!.absoluteString : ""
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

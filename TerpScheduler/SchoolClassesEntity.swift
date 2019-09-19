//
//  SchoolClassesModel.swift
//  TerpScheduler
//
//  Created by Ben Hall on 1/5/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import Foundation
import CoreData

/// Data structure for handling the information about the assigned classes.
struct SchoolClass {
  let period: Int //1-indexed.
  let teacherName: String
  let haikuURL: URL?
  let isStudyHall: Bool
  let subject: String
  let isLocked: Bool
  let id: NSManagedObjectID?

  /// Generates a default, empty object for the specified period.
  ///
  /// - Parameter period: The class period to generate for. 0-indexed.
  /// - Returns: A new, empty `SchoolClass` instance with the period set appropriately.
  static func defaultForPeriod(_ period: Int) -> SchoolClass {
    //sometimes there's a disconnect and a 0-indexed period gets passed in. Sigh. Hack.
    return SchoolClass(period: period+1, teacherName: "", haikuURL: nil, isStudyHall: false, subject: "", isLocked: false, id: nil)
  }

    
  /// Handles the case of a middle-school student for 7th period, which shows "sports" and is locked.
  ///
  /// - Returns: the value for middle school sports.
  static func middleSchoolSports() -> SchoolClass {
    return SchoolClass(period: 7, teacherName: "", haikuURL: nil, isStudyHall: false, subject: "Sports", isLocked: true, id: nil)
  }
}

extension SchoolClass: DataObject {
  init(entity: NSManagedObject) {
    guard let entity = entity as? SchoolClassesEntity else {
      NSLog("Critical Error: SchoolClassesEntity not found.")
      abort()
    }
    period = entity.classPeriod.intValue
    teacherName = entity.teacherName
    if entity.haikuURL != ""{
      haikuURL = URL(string: entity.haikuURL)
    } else {
      haikuURL = nil
    }
    isStudyHall = entity.isStudyHall
    subject = entity.subject
    isLocked = entity.isLocked
    id = entity.objectID
  }

    /// Converts a `SchoolClass` into a `SchoolClassEntity` with the same data.
    ///
    /// - Parameters:
    ///   - context: `NSManagedObjectContext` for the entry.
    ///   - isNew: `true` if a new object (not already stored)
    /// - Returns: A `SchoolClassEntity` with the appropriate data.
    func toEntity(inContext context: NSManagedObjectContext, isNew: Bool) -> NSManagedObject {
    var managedObject: SchoolClassesEntity?
    var alreadyExists = false
    if self.id != nil {
      let existingEntity: NSManagedObject?
      do {
        existingEntity = try context.existingObject(with: self.id!)
      } catch let error as NSError {
        existingEntity = nil
        NSLog("%@", error)
      }
      if existingEntity != nil {
        managedObject = existingEntity! as? SchoolClassesEntity
        alreadyExists = true
      }
    }
    if !alreadyExists {
      let entity = NSEntityDescription.entity(forEntityName: "SchoolClasses", in: context)
      managedObject = SchoolClassesEntity(entity: entity!, insertInto: context)
    }
    managedObject!.classPeriod = NSNumber(value: period)
    managedObject!.teacherName = teacherName
    managedObject!.haikuURL = haikuURL != nil ? haikuURL!.absoluteString : ""
    managedObject!.isStudyHall = isStudyHall
    managedObject!.subject = subject
    managedObject!.isLocked = isLocked
    return managedObject!
  }
}

/// The managed entity for school class data.
class SchoolClassesEntity: NSManagedObject {
  @NSManaged var classPeriod: NSNumber
  @NSManaged var teacherName: String
  @NSManaged var haikuURL: String
  @NSManaged var isStudyHall: Bool
  @NSManaged var subject: String
  @NSManaged var isLocked: Bool
}

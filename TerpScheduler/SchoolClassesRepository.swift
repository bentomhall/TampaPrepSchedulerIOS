//
//  SchoolClassesRepository.swift
//  TerpScheduler
//
//  Created by Ben Hall on 1/11/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import UIKit
import CoreData

class SchoolClassesRepository: NSObject {
  fileprivate var managedContext: NSManagedObjectContext
  fileprivate let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "SchoolClasses")

  init(context: NSManagedObjectContext) {
    managedContext = context
  }

  fileprivate func fetchEntity(_ classPeriod: Int) -> SchoolClassesEntity? {
    let predicate = NSPredicate(format: "classPeriod = %i", classPeriod)
    fetchRequest.predicate = predicate
    fetchRequest.returnsObjectsAsFaults = false
    do {
      let results = try managedContext.fetch(fetchRequest)
      if results.count > 0 {
        if let entity = results[0] as? SchoolClassesEntity {
          return entity
        }
      }
    } catch let error as NSError {
      NSLog("error fetching class period: %@", error)
    }
    return nil
  }

  func getClassDataByPeriod(_ classPeriod: Int) -> SchoolClass {
    if let classEntity = fetchEntity(classPeriod + 1) {
      let newClass = SchoolClass(entity: classEntity as NSManagedObject)
      return newClass
    }
    return SchoolClass.defaultForPeriod(classPeriod)
  }

  func removeAllFor(_ period: Int) {
    let predicate = NSPredicate(format: "classPeriod = %i", period)
    fetchRequest.predicate = predicate
    fetchRequest.returnsObjectsAsFaults = false
    do {
      let results = try managedContext.fetch(fetchRequest)
      if results.count > 1 {
        for result in results {
          guard let managedResult = result as? NSManagedObject else {
            NSLog("World consistency violation--result of fetch request not a managed object")
            break
          }
          managedContext.delete(managedResult)
        }
      }
    } catch let error as NSError {
      NSLog("Error removing extra class periods: %@", error)
    }
  }

  func persistData(_ classData: SchoolClass) {
    removeAllFor(classData.period) //ensure there can only be one (the most recent)
    guard let _ = classData.toEntity(inContext: managedContext, isNew: true) as? SchoolClassesEntity else {
      NSLog("World consistency violation: class data cannot convert to entity")
      abort()
    }
    do {
      try managedContext.save()
    } catch let error as NSError {
      NSLog("Error saving classes: %@", error)
    }

  }

  func getMiddleSchoolSports() -> SchoolClass {
    return SchoolClass.middleSchoolSports()
  }
}

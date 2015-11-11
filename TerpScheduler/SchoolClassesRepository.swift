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
  private var managedContext : NSManagedObjectContext
  private let fetchRequest = NSFetchRequest(entityName: "SchoolClasses")
  
  init(context: NSManagedObjectContext){
    managedContext = context
  }
  
  private func fetchEntity(classPeriod: Int) -> SchoolClassesEntity? {
    let predicate = NSPredicate(format: "classPeriod = %i", classPeriod)
    fetchRequest.predicate = predicate
    fetchRequest.returnsObjectsAsFaults = false
    do {
      let results = try managedContext.executeFetchRequest(fetchRequest)
      if results.count > 0 {
        return (results[0] as! SchoolClassesEntity)
      }
    } catch let error as NSError {
      NSLog("error fetching class period: %@", error)
    }
    return nil
  }
  
  func getClassDataByPeriod(classPeriod: Int)->SchoolClass{
    if let classEntity = fetchEntity(classPeriod + 1) {
      let newClass = SchoolClass(entity: classEntity as NSManagedObject)
      return newClass
    }
    return SchoolClass.defaultForPeriod(classPeriod)
  }
  
  func removeAllFor(period: Int){
    let predicate = NSPredicate(format: "classPeriod = %i", period)
    fetchRequest.predicate = predicate
    fetchRequest.returnsObjectsAsFaults = false
    do {
      let results = try managedContext.executeFetchRequest(fetchRequest)
      NSLog("%i", results.count)
      if results.count > 1 {
        for result in results {
          managedContext.deleteObject(result as! NSManagedObject)
        }
      }
    } catch let error as NSError {
      NSLog("Error removing objects")
      NSLog("%@", error)
    }
  }
  
  func persistData(classData : SchoolClass){
    removeAllFor(classData.period) //ensure there can only be one (the most recent)
    let _ = classData.toEntity(inContext: managedContext) as! SchoolClassesEntity
    do {
      try managedContext.save()
    } catch let error as NSError {
      NSLog("Error Saving objects")
      NSLog("%@", error)
    }

  }
  
  func getMiddleSchoolSports()->SchoolClass{
    return SchoolClass.middleSchoolSports()
  }
}

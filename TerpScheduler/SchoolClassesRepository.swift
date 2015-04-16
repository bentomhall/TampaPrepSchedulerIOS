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
    let predicate = NSPredicate(format: "classPeriod = %i", classPeriod + 1)
    fetchRequest.predicate = predicate
    fetchRequest.returnsObjectsAsFaults = false
    var error: NSError?
    if let results = managedContext.executeFetchRequest(fetchRequest, error: &error){
      if error != nil {
        NSLog("%@", error!)
      }
      if results.count == 1 {
        return (results[0] as! SchoolClassesEntity)
      }
    }
    return nil
  }
  
  func getClassDataByPeriod(classPeriod: Int)->SchoolClass{
    if let classEntity = fetchEntity(classPeriod) {
      let newClass = SchoolClass(entity: classEntity as NSManagedObject)
      return newClass
    }
    return SchoolClass.defaultForPeriod(classPeriod)
  }
  
  func persistData(classData : SchoolClass){
    var entity = classData.toEntity(inContext: managedContext)
    var error: NSError?
    managedContext.save(&error)
    if error != nil {
      NSLog("%@", error!)
    }
  }
}

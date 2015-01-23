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
    fetchRequest.predicate = predicate!
    if let results = managedContext.executeFetchRequest(fetchRequest, error: nil){
      if results.count == 1 {
        return (results[0] as SchoolClassesEntity)
      }
    }
    return nil
  }
  
  func GetClassDataByPeriod(classPeriod: Int)->SchoolClass{
    if let classEntity = fetchEntity(classPeriod) {
      let newClass = SchoolClass(entity: classEntity as NSManagedObject)
      return newClass
    }
    return SchoolClass.DefaultForPeriod(classPeriod)
  }
  
   func persistData(classData : SchoolClass){
    var entity = fetchEntity(classData.period)
    managedContext.save(nil)
  }
}

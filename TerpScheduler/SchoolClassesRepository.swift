//
//  SchoolClassesRepository.swift
//  TerpScheduler
//
//  Created by Ben Hall on 1/11/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import UIKit
import CoreData

struct ClassPeriodData {
    var ClassPeriod : Int
    var TeacherName : String
    var HaikuURL : NSURL?
    var IsStudyHall : Bool
    var Subject : String
    
    static func DefaultForPeriod(period: Int)->ClassPeriodData{
        return ClassPeriodData(ClassPeriod: period, TeacherName: "No Teacher Selected", HaikuURL: nil, IsStudyHall: false, Subject: "No Subject Selected")
    }
}

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
  
  func GetClassDataByPeriod(classPeriod: Int)->ClassPeriodData{
    if let entity = fetchEntity(classPeriod) {
      return extractClassDataFromModel(entity)
    }
    return ClassPeriodData.DefaultForPeriod(classPeriod)
  }
  
  private func extractClassDataFromModel(model : SchoolClassesEntity)->ClassPeriodData{
    let classPeriod = model.valueForKey("classPeriod") as Int
    let teacherName = model.valueForKey("teacherName") as String
    let haikuURL = model.valueForKey("haikuURL") as String
    let isStudyHall = model.valueForKey("isStudyHall") as Bool
    let subject = model.valueForKey("subject") as String
    return ClassPeriodData(ClassPeriod: classPeriod, TeacherName: teacherName, HaikuURL: NSURL(string: haikuURL), IsStudyHall: isStudyHall, Subject: subject)
  }
  
   func persistData(classData : ClassPeriodData){
    func setModelContents(model: SchoolClassesEntity, fromData classData : ClassPeriodData){
      model.classPeriod = classData.ClassPeriod
      model.subject = classData.Subject
      model.isStudyHall = classData.IsStudyHall
      model.teacherName = classData.TeacherName
      if let url = classData.HaikuURL {
        model.haikuURL = url.absoluteString!
      } else {
        model.haikuURL = ""
      }
    }
    
    if let entity = fetchEntity(classData.ClassPeriod){
      setModelContents(entity, fromData: classData)
    }
    else {
      let entity = NSEntityDescription.entityForName("SchoolClasses", inManagedObjectContext: managedContext)
      var model = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext) as SchoolClassesEntity
      setModelContents(model, fromData: classData)
    }
    managedContext.save(nil)
  }
}

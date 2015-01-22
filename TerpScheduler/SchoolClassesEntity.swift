//
//  SchoolClassesModel.swift
//  TerpScheduler
//
//  Created by Ben Hall on 1/5/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import Foundation
import CoreData

struct SchoolClass: Filterable {
  let date = NSDate() //garbage
  let period: Int
  let id: NSUUID
  let teacherName: String
  let haikuURL: NSURL?
  let isStudyHall: Bool
  let subject: String
}

extension SchoolClass: DataObject{
  init(entity: NSManagedObject){
    let entity = entity as SchoolClassesEntity
    period = entity.classPeriod
    id = NSUUID()
    teacherName = entity.teacherName
    if entity.haikuURL != ""{
      haikuURL = NSURL(string: entity.haikuURL)
    }
    isStudyHall = entity.isStudyHall
    subject = entity.subject
  }
}

class SchoolClassesEntity: NSManagedObject {
    @NSManaged var classPeriod : Int
    @NSManaged var teacherName : String
    @NSManaged var haikuURL : String
    @NSManaged var isStudyHall : Bool
    @NSManaged var subject: String
}

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
    
    static func Default()->ClassPeriodData{
        return ClassPeriodData(ClassPeriod: 1, TeacherName: "No Teacher Selected", HaikuURL: nil, IsStudyHall: false, Subject: "No Subject Selected")
    }
}

class SchoolClassesRepository: NSObject {
    var managedContext : NSManagedObjectContext
    
    
    init(context: NSManagedObjectContext){
        managedContext = context
    }
    
    func GetClassDataByPeriod(classPeriod: Int)->ClassPeriodData{
        let fetchRequest = NSFetchRequest(entityName: "SchoolClasses")
        let predicate = NSPredicate(format: "classPeriod = %i", classPeriod)
        fetchRequest.predicate = predicate!
        if let results = managedContext.executeFetchRequest(fetchRequest, error: nil){
            if results.count == 1 {
                return ExtractClassDataFromModel(results[0] as SchoolClassesModel)
            }
        }
        return ClassPeriodData.Default()
    }
    
    func ExtractClassDataFromModel(model : SchoolClassesModel)->ClassPeriodData{
        let classPeriod = model.valueForKey("classPeriod") as Int
        let teacherName = model.valueForKey("teacherName") as String
        let haikuURL = model.valueForKey("haikuURL") as String
        let isStudyHall = model.valueForKey("isStudyHall") as Bool
        let subject = model.valueForKey("subject") as String
        return ClassPeriodData(ClassPeriod: classPeriod, TeacherName: teacherName, HaikuURL: NSURL(string: haikuURL), IsStudyHall: isStudyHall, Subject: subject)
    }
    
    func SetClassModelFromData(classData : ClassPeriodData){
        let entity = NSEntityDescription.entityForName("SchoolClasses", inManagedObjectContext: managedContext)
        var data = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        data.setValue(classData.ClassPeriod, forKey: "classPeriod")
        data.setValue(classData.TeacherName, forKey: "teacherName")
        data.setValue(classData.IsStudyHall, forKey: "isStudyHall")
        data.setValue(classData.Subject, forKey: "subject")
        if let url = classData.HaikuURL {
            data.setValue(url.absoluteString, forKey: "haikuURL")
        } else {
            data.setValue(nil, forKey: "haikuURL")
        }
        managedContext.save(nil)
    }
}

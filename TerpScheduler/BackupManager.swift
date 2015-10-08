//
//  BackupManager.swift
//  TerpScheduler
//
//  Created by Ben Hall on 8/4/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import Foundation

class BackupManager {
  private let taskRepository: TaskRepository
  private let fileManager: NSFileManager
  private let documentDirectory: NSURL
  private let backupBaseName = "TerpSchedulerBackup"
  private let backupWriter: JsonBackupWriter
  private let backupReader: JsonBackupReader
  
  init(repository: TaskRepository){
    taskRepository = repository
    fileManager = NSFileManager.defaultManager()
    documentDirectory = try! fileManager.URLForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomain: NSSearchPathDomainMask.UserDomainMask, appropriateForURL: nil, create: true)
    backupWriter = JsonBackupWriter(filePath: documentDirectory.URLByAppendingPathComponent(backupBaseName))
    backupReader = JsonBackupReader(filePath: documentDirectory.URLByAppendingPathComponent(backupBaseName))
  }
  
  private func shouldMakeBackup()->Bool{
    let path = documentDirectory.URLByAppendingPathComponent(backupBaseName).path!
    let oneDayAgo = NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: -1, toDate: NSDate(), options: [])
    if let attributes = try? fileManager.attributesOfItemAtPath(path) {
      let lastModified = attributes[NSFileCreationDate]! as! NSDate
      if lastModified.compare(oneDayAgo!) == NSComparisonResult.OrderedAscending {
        return true
      } else {
        return false
      }
    } else {
      return false
    }
  }
  
  private func gatherDataForBackup()-> [[String: AnyObject]]{
    //let allTasks = taskRepository.allTasks()
    let output = [[String: AnyObject]]()
    //for task in allTasks {
      //output.append(task.contentsAsDictionary())
    //}
    return output
  }
  
  ///Creates a backup of all tasks to JSON file if force parameter is true, or if the last backup was more than a day ago. Note, if no backup exists a new one will be made.
  ///
  ///- parameter force: Indicates the backup should be done regardless of last backup date.
  func makeBackup(force: Bool){
    if force || shouldMakeBackup() {
      let data = gatherDataForBackup()
      if data.count == 1 {
        //only the default task is present, so skip the backup
        return
      } else {
        backupWriter.makeBackupFrom(data)
      }
    }
  }
  
  private func shouldReadBackup(force: Bool)->Bool{
    let repositoryCount = taskRepository.countAllTasks()
    let path = documentDirectory.URLByAppendingPathComponent(backupBaseName).path!
    if force || repositoryCount == 0 {
      if fileManager.isReadableFileAtPath(path){
        return true
      } else {
        return false
      }
    } else {
      return false
    }
  }
  
  private func createTaskFrom(dictionary: [String: AnyObject])->DailyTask{
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "MM/dd/yyyy"
    let date = dateFormatter.dateFromString(dictionary["date"]! as! String)!
    let period = dictionary["period"] as! Int
    let shortTitle = dictionary["shortTitle"]! as! String
    let details = dictionary["details"]! as! String
    let isCompleted = Bool(dictionary["isCompleted"]! as! Int)
    let isHaikuAssignment = Bool(dictionary["isHaikuAssignment"]! as! Int)
    let priority = Priorities(rawValue: dictionary["priority"]! as! Int)!
    let shouldNotify = Bool(dictionary["shouldNotify"]! as! Int)
    
    return DailyTask(date: date, period: period, shortTitle: shortTitle, details: details, isHaiku: isHaikuAssignment, completion: isCompleted, priority: priority, notify: shouldNotify)
  }
  
  private func loadDataFromBackup()-> [DailyTask]{
    var deserializedData = [DailyTask]()
    if let data = backupReader.deserializeBackup() {
      for dict in data {
        deserializedData.append(createTaskFrom(dict))
      }
    }
    return deserializedData
  }
  
  func readBackup(force: Bool){
    if shouldReadBackup(force){
      let tasks = loadDataFromBackup()
      taskRepository.persistTasks(tasks)
    }
  }
}

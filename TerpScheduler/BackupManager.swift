//
//  BackupManager.swift
//  TerpScheduler
//
//  Created by Ben Hall on 8/4/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import Foundation

class BackupManager {
  fileprivate let taskRepository: TaskRepository
  fileprivate let fileManager: FileManager
  fileprivate let documentDirectory: URL
  fileprivate let backupBaseName = "TerpSchedulerBackup"
  fileprivate let backupWriter: JsonBackupWriter
  fileprivate let backupReader: JsonBackupReader
  
  init(repository: TaskRepository){
    taskRepository = repository
    fileManager = FileManager.default
    documentDirectory = try! fileManager.url(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor: nil, create: true)
    backupWriter = JsonBackupWriter(filePath: documentDirectory.appendingPathComponent(backupBaseName))
    backupReader = JsonBackupReader(filePath: documentDirectory.appendingPathComponent(backupBaseName))
  }
  
  fileprivate func shouldMakeBackup()->Bool{
    let path = documentDirectory.appendingPathComponent(backupBaseName).path
    let oneDayAgo = (Calendar.current as NSCalendar).date(byAdding: .day, value: -1, to: Date(), options: [])
    if let attributes = try? fileManager.attributesOfItem(atPath: path) {
      let lastModified = attributes[FileAttributeKey.creationDate]! as! Date
      if lastModified.compare(oneDayAgo!) == ComparisonResult.orderedAscending {
        return true
      } else {
        return false
      }
    } else {
      return false
    }
  }
  
  fileprivate func gatherDataForBackup()-> [[String: AnyObject]]{
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
  func makeBackup(_ force: Bool){
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
  
  fileprivate func shouldReadBackup(_ force: Bool)->Bool{
    let repositoryCount = taskRepository.countAllTasks()
    let path = documentDirectory.appendingPathComponent(backupBaseName).path
    if force || repositoryCount == 0 {
      if fileManager.isReadableFile(atPath: path){
        return true
      } else {
        return false
      }
    } else {
      return false
    }
  }
  
  fileprivate func createTaskFrom(_ dictionary: [String: AnyObject])->DailyTask{
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM/dd/yyyy"
    let date = dateFormatter.date(from: dictionary["date"]! as! String)!
    let period = dictionary["period"] as! Int
    let shortTitle = dictionary["shortTitle"]! as! String
    let details = dictionary["details"]! as! String
    let isCompleted = Bool(dictionary["isCompleted"]! as! Int)
    let isHaikuAssignment = Bool(dictionary["isHaikuAssignment"]! as! Int)
    let priority = Priorities(rawValue: dictionary["priority"]! as! Int)!
    let shouldNotify = Bool(dictionary["shouldNotify"]! as! Int)
    
    return DailyTask(date: date, period: period, shortTitle: shortTitle, details: details, isHaiku: isHaikuAssignment, completion: isCompleted, priority: priority, notify: shouldNotify)
  }
  
  fileprivate func loadDataFromBackup()-> [DailyTask]{
    var deserializedData = [DailyTask]()
    if let data = backupReader.deserializeBackup() {
      for dict in data {
        deserializedData.append(createTaskFrom(dict))
      }
    }
    return deserializedData
  }
  
  func readBackup(_ force: Bool){
    if shouldReadBackup(force){
      let tasks = loadDataFromBackup()
      taskRepository.persistTasks(tasks)
    }
  }
}

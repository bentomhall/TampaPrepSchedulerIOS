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
  
  init(repository: TaskRepository){
    taskRepository = repository
    fileManager = NSFileManager.defaultManager()
    documentDirectory = fileManager.URLForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomain: NSSearchPathDomainMask.UserDomainMask, appropriateForURL: nil, create: true, error: nil)!
    backupWriter = JsonBackupWriter(filePath: documentDirectory.URLByAppendingPathComponent(backupBaseName))
  }
  
  private func shouldMakeBackup()->Bool{
    let path = documentDirectory.path!.stringByAppendingPathComponent(backupBaseName)
    let oneDayAgo = NSCalendar.currentCalendar().dateByAddingUnit(.CalendarUnitDay, value: -1, toDate: NSDate(), options: .allZeros)
    if let attributes = fileManager.attributesOfItemAtPath(path, error: nil) {
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
    let allTasks = taskRepository.allTasks()
    var output = [[String: AnyObject]]()
    for task in allTasks {
      output.append(task.contentsAsDictionary())
    }
    return output
  }
  
  ///Creates a backup of all tasks to JSON file if force parameter is true, or if the last backup was more than a day ago. Note, if no backup exists a new one will be made.
  ///
  ///:param: force Indicates the backup should be done regardless of last backup date.
  func makeBackup(force: Bool){
    if force || shouldMakeBackup() {
      let data = gatherDataForBackup()
      backupWriter.makeBackupFrom(data)
    }
  }
}

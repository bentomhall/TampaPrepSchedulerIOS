//
//  JsonBackupWriter.swift
//  TerpScheduler
//
//  Created by Ben Hall on 8/4/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import Foundation

class JsonBackupWriter {
  let path: NSURL
  let dateFormatter = NSDateFormatter()
  
  init(filePath: NSURL){
    path = filePath
    dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
  }
  
  func serialize(data: AnyObject)->NSData? {
    if NSJSONSerialization.isValidJSONObject(data) {
      return try? NSJSONSerialization.dataWithJSONObject(data, options: NSJSONWritingOptions.PrettyPrinted)
    } else {
      return nil
    }
  }
  
  func writeToFile(data: NSData){
    var err: NSError?
    let outputStream = NSOutputStream(URL: path, append: false)
    if outputStream != nil {
      NSJSONSerialization.writeJSONObject(data, toStream: outputStream!, options: NSJSONWritingOptions(), error: &err)
    }
  }
  
  //Needs error handling
  func makeBackupFrom(data: [AnyObject])->Bool{
    let count = data.count
    var backupData = [String: AnyObject]()
    backupData["created"] = dateFormatter.stringFromDate(NSDate())
    backupData["count"] = count
    backupData["data"] = data
    
    if let jsonData = serialize(backupData) {
      let dispach_priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
      dispatch_async(dispatch_get_global_queue(dispach_priority, 0))
        {
          self.writeToFile(jsonData)
        }
      return true
    } else {
      return false
    }
  }
}
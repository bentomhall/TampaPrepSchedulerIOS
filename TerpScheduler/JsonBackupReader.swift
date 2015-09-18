//
//  JsonBackupReader.swift
//  TerpScheduler
//
//  Created by Ben Hall on 8/4/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import Foundation

class JsonBackupReader {
  let path: NSURL
  let dateFormatter = NSDateFormatter()
  var itemCount: Int?
  var dateCreated: NSDate?
  
  init(filePath: NSURL){
    path = filePath
    dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
  }
  
  func deserializeBackup()->[[String: AnyObject]]?{
    if let inputStream = NSInputStream(URL: path) {
      let fileContents = (try! NSJSONSerialization.JSONObjectWithStream(inputStream, options: [])) as! [String: AnyObject]
      
      dateCreated = dateFormatter.dateFromString(fileContents["created"]! as! String)
      itemCount = fileContents["count"] as? Int
      
      if itemCount > 0 {
        return fileContents["data"] as? [[String: AnyObject]]
      } else {
        return nil
      }
    } else {
      return nil
    }
  }
  
  
}
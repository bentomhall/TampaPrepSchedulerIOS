//
//  JsonBackupReader.swift
//  TerpScheduler
//
//  Created by Ben Hall on 8/4/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import Foundation
fileprivate func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

class JsonBackupReader {
  let path: URL
  let dateFormatter = DateFormatter()
  var itemCount: Int?
  var dateCreated: Date?

  init(filePath: URL) {
    path = filePath
    dateFormatter.dateStyle = DateFormatter.Style.short
  }

  func deserializeBackup() -> [[String: AnyObject]]? {
    if let inputStream = InputStream(url: path) {
      let fileContents = (try? JSONSerialization.jsonObject(with: inputStream, options: [])) as? [String: AnyObject]

      dateCreated = dateFormatter.date(from: (fileContents!["created"]! as? String)!)
      itemCount = fileContents!["count"] as? Int

      if itemCount > 0 {
        return fileContents!["data"] as? [[String: AnyObject]]
      } else {
        return nil
      }
    } else {
      return nil
    }
  }
}

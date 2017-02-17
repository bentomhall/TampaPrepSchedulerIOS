//
//  JsonBackupWriter.swift
//  TerpScheduler
//
//  Created by Ben Hall on 8/4/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import Foundation

class JsonBackupWriter {
  let path: URL
  let dateFormatter = DateFormatter()

  init(filePath: URL) {
    path = filePath
    dateFormatter.dateStyle = DateFormatter.Style.short
  }

  func serialize(_ data: AnyObject) -> Data? {
    if JSONSerialization.isValidJSONObject(data) {
      return try? JSONSerialization.data(withJSONObject: data, options: JSONSerialization.WritingOptions.prettyPrinted)
    } else {
      return nil
    }
  }

  func writeToFile(_ data: Data) {
    var err: NSError?
    let outputStream = OutputStream(url: path, append: false)
    if outputStream != nil {
      JSONSerialization.writeJSONObject(data, to: outputStream!, options: JSONSerialization.WritingOptions(), error: &err)
    }
  }

  //Needs error handling
  func makeBackupFrom(_ data: [String: AnyObject]) -> Bool {
    let count = data.count
    var backupData = data
    backupData["created"] = dateFormatter.string(from: Date()) as AnyObject?
    backupData["count"] = count as AnyObject?
    backupData["data"] = data as AnyObject?

    if let jsonData = serialize(backupData as AnyObject) {
      let queue = DispatchQueue(label: "com.terpscheduler.background", qos: .background, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
      queue.async {
          self.writeToFile(jsonData)
        }
      return true
    } else {
      return false
    }
  }
}

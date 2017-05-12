//
//  NetworkScheduleUpdater.swift
//  TerpScheduler
//
//  Created by Ben Hall on 4/27/17.
//  Copyright © 2017 Tampa Preparatory School. All rights reserved.
//

import Foundation

protocol ScheduleUpdateDelegate: class {
  func scheduleDidUpdateFromNetwork(newSchedule: [String: Any])
  func networkScheduleUpdateFailed(error: Error)
  func scheduleTypesDidUpdateFromNetwork(newTypeDefinitions: [String: Any])
}

enum ScheduleUpdateError: Error {
  case NetworkFailure(String)
  case ImproperResponse(String)
}

class NetworkScheduleUpdater {
  private let defaults: CustomUserDefaults
  private weak var delegate: ScheduleUpdateDelegate?
  private var scheduleData: [String: Any]?

  init(defaults: CustomUserDefaults, delegate: ScheduleUpdateDelegate) {
    self.defaults = defaults
    self.delegate = delegate
  }

  func shouldUpdateFromNetwork() -> Bool {
    let lastUpdate = dateFromString(defaults.lastScheduleUpdate)
    let now = Date()
    //return false //network side of things not active currently
    return (Calendar.current.dateComponents([.day], from: lastUpdate, to: now).day ?? 0) > defaults.scheduleUpdateFrequency
  }

  func retrieveScheduleFromNetwork(withDefinitions: Bool, forDate: Date = Date()) {
    let schoolYear = getSchoolYear(forDate)
    let url = URL(string: "https://teaching.admiralbenbo.org/schedule/\(schoolYear)")!
    let config = URLSessionConfiguration.ephemeral
    let session = URLSession(configuration: config)
    let task = session.dataTask(with: url, completionHandler: onResponseReceived)
    task.resume()
  }
  
  func retrieveScheduleTypesFromNetwork(forDate: Date = Date()) {
    let schoolYear = getSchoolYear(forDate)
    let url = URL(string: "https://teaching.admiralbenbo.org/definitions/\(schoolYear)")!
    let config = URLSessionConfiguration.ephemeral
    let session = URLSession(configuration: config)
    let task = session.dataTask(with: url, completionHandler: scheduleTypesDidUpdate)
    task.resume()
  }
  
  func scheduleTypesDidUpdate(data: Data?, response: URLResponse?, error: Error?) {
    guard error == nil else {
      delegate!.networkScheduleUpdateFailed(error: ScheduleUpdateError.NetworkFailure(error!.localizedDescription))
      return
    }
    if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any] {
      guard json!.count > 1 else {
        delegate!.networkScheduleUpdateFailed(error: ScheduleUpdateError.ImproperResponse("Server Error: \(json!["message"] ?? "Year Not recognized")"))
        return
      }
      self.delegate!.scheduleTypesDidUpdateFromNetwork(newTypeDefinitions: json!)
    }
  }

  func onResponseReceived(data: Data?, response: URLResponse?, error: Error? ) {
//    guard delegate == nil else {
//      NSLog("No delegate found for NetworkScheduleUpdater")
//      return
//    }
    guard error == nil else {
      delegate!.networkScheduleUpdateFailed(error: ScheduleUpdateError.NetworkFailure(error!.localizedDescription))
      return
    }
    if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any] {
      guard json!.count > 1 else {
        delegate!.networkScheduleUpdateFailed(error: ScheduleUpdateError.ImproperResponse("Server Error: \(json!["message"] ?? "Year Not recognized")"))
        return
      }

      self.delegate!.scheduleDidUpdateFromNetwork(newSchedule: json!)
      let dateFormatter = DateFormatter()
      dateFormatter.dateStyle = .medium
      self.defaults.lastScheduleUpdate = dateFormatter.string(from: Date())
    }
  }
}

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
  func scheduleUpdateUnnecessary()
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
    let updateDelta = Date(timeIntervalSince1970: defaults.lastScheduleUpdate).timeIntervalSinceNow //this is negative
    return updateDelta.isLessThanOrEqualTo(-15780000.0) //six months
  }

    /// Async; sends request for update from API. Format is /api/schedule/<year>?update=<last update>
  ///
    /// TODO: change URL to whatever will be used after I'm gone.
  /// - Parameters:
  ///   - withDefinitions: unused
  ///   - forDate: the date (for the school year) to get updates for. Generally this should be today's date.
  func retrieveScheduleFromNetwork(withDefinitions: Bool, forDate: Date = Date()) {
    let schoolYear = getSchoolYear(forDate)
    let lastUpdate = defaults.lastScheduleUpdate
    let url = URL(string: "https://teaching.admiralbenbo.org/api/schedule/\(schoolYear)?update=\(lastUpdate)")!
    let config = URLSessionConfiguration.ephemeral
    let session = URLSession(configuration: config)
    let task = session.dataTask(with: url, completionHandler: onResponseReceived)
    task.resume()
  }
  
  func retrieveScheduleTypesFromNetwork(forDate: Date = Date()) {
    let schoolYear = getSchoolYear(forDate)
    let url = URL(string: "https://teaching.admiralbenbo.org/api/definitions/\(schoolYear)")!
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
      if json.count == 0 {
        self.defaults.lastScheduleUpdate = Date().timeIntervalSince1970
        return
      }
      guard json.count > 1 else {
        delegate!.networkScheduleUpdateFailed(error: ScheduleUpdateError.ImproperResponse("Server Error: \(json["message"] ?? "Year Not recognized")"))
        return
      }
      self.delegate!.scheduleTypesDidUpdateFromNetwork(newTypeDefinitions: json)
    }
  }

  func onResponseReceived(data: Data?, response: URLResponse?, error: Error? ) {
    guard error == nil else {
      delegate!.networkScheduleUpdateFailed(error: ScheduleUpdateError.NetworkFailure(error!.localizedDescription))
      return
    }
    if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any] {
      if json.count == 0 {
        self.defaults.lastScheduleUpdate = Date().timeIntervalSince1970
        self.delegate!.scheduleUpdateUnnecessary()
        return
      }
      guard json.count > 1 else {
        delegate!.networkScheduleUpdateFailed(error: ScheduleUpdateError.ImproperResponse("Server Error: \(json["message"] ?? "Year Not recognized")"))
        return
      }

      self.delegate!.scheduleDidUpdateFromNetwork(newSchedule: json)
      self.defaults.lastScheduleUpdate = Date().timeIntervalSince1970
    }
  }
}

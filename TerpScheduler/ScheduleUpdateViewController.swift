//
//  ScheduleUpdateViewController.swift
//  TerpScheduler
//
//  Created by Ben Hall on 5/5/17.
//  Copyright © 2017 Tampa Preparatory School. All rights reserved.
//

import UIKit

class ScheduleUpdateController: ScheduleUpdateDelegate {
  
  func scheduleTypesDidUpdateFromNetwork(newTypeDefinitions: [String : Any]) {
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    appDelegate!.scheduleTypes = ScheduleTypeData(data: newTypeDefinitions)
    do {
      try scheduleLoader!.saveScheduleTypesToDisk(data: newTypeDefinitions)
    } catch let error as NSError {
      NSLog("Error saving schedule types to disk: %@. Is the disk full?", error)
    }
  }

  weak var delegate: DateInformationDelegate?
  var networkLoader: NetworkScheduleUpdater?
  var userDefaults: CustomUserDefaults?
  var scheduleLoader: SemesterScheduleLoader?
  var isUpdating: Bool = true
  weak var activityIndicator: UIActivityIndicatorView?
  
  init(activity: UIActivityIndicatorView) {
    activityIndicator = activity
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    userDefaults = appDelegate!.userDefaults
    delegate = appDelegate!.dataManager
    scheduleLoader = appDelegate!.scheduleLoader
    networkLoader = NetworkScheduleUpdater(defaults: userDefaults!, delegate: self)
  }
  
  func willUpdateFromNetwork() {
    //if networkLoader!.shouldUpdateFromNetwork() {
      activityIndicator!.startAnimating()
      networkLoader!.retrieveScheduleFromNetwork(withDefinitions: false)
    //}
  }
  
  func scheduleDidUpdateFromNetwork(newSchedule: [String : Any]) {
    //pop up notification
    scheduleLoader!.scheduleDidUpdateFromNetwork(newSchedule: newSchedule)
    activityIndicator!.stopAnimating()
    delegate!.didUpdateSchedulesForWeekInView()
  }
  
  func networkScheduleUpdateFailed(error: Error) {
    NSLog("%@", error.localizedDescription)
  }

}

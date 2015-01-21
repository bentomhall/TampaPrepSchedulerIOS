//
//  TaskSplitViewController.swift
//  TerpScheduler
//
//  Created by Ben Hall on 1/20/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import UIKit

protocol TaskDataSource{
  var date: NSDate { get }
  var period: Int { get }
  var repository: TaskCollectionRepository? { get set }
}

class TaskSplitViewController: UISplitViewController, TaskDataSource {
  var date = NSDate()
  var period = 0
  var repository: TaskCollectionRepository?
  var tasks: [DailyTaskData] = []
  
  override func viewDidLoad() {
    if repository != nil {
      tasks = repository!.tasksForDateAndPeriod(date, period: period)
    }
  }
  
  func setTableViewData(){
    let master = viewControllers[0] as UINavigationController
  }
  
}

//
//  BusinessModel.swift
//  TerpScheduler
//
//  Created by Ben Hall on 1/21/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import UIKit
import CoreData



protocol TaskDetailDelegate{
  func updateTask(task: DailyTask)
  var detailViewController: TaskDetailViewController? {get set}
}

protocol TaskTableDelegate {
  func willDisplayDetailForTaskByID(id: NSUUID?, forViewController: TaskDetailViewController)
  var tableViewController: TaskTableViewController? { get set }
  var defaultTask: DailyTask { get }
  func didDeleteTask(task: DailyTask)
  func willDisappear()
}

protocol TaskSummaryDelegate {
  func willDisplaySplitViewFor(date: NSDate, period: Int)
  func summariesForWeek()->[TaskSummary]
  var summaryViewController: MainViewController? { get set }
  var detailViewController: TaskDetailViewController? { get set }
  var datesForWeek: [SchoolDate] { get }
  func didSetDateByIndex(index: Int, withData data: String)
  func loadWeek(direction: Int)
  func missedClassesForDayByIndex(index: Int)->[Int]
}

class DataManager: TaskDetailDelegate, TaskTableDelegate, TaskSummaryDelegate {
  init(){
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    managedObjectContext = appDelegate.managedObjectContext!
    taskRepository = TaskRepository(context: managedObjectContext)
    dateRepository = DateRepository(context: managedObjectContext)
    schoolClassRepository = SchoolClassesRepository(context: managedObjectContext)
  }
  
  private var managedObjectContext: NSManagedObjectContext
  private var taskRepository: TaskRepository
  private var dateRepository: DateRepository
  private var schoolClassRepository: SchoolClassesRepository
  private var selectedDate = NSDate()
  private var selectedPeriod = 1
  var detailViewController: TaskDetailViewController?
  var summaryViewController: MainViewController?
  var tableViewController: TaskTableViewController?
  var datesForWeek: [SchoolDate]{
    get { return dateRepository.dates }
  }
  var defaultTask: DailyTask {
    get { return taskRepository.defaultTask! }
  }
  
  
  
  func updateTask(task: DailyTask) {
    taskRepository.persistData(task)
    summaryViewController!.reloadCollectionView()
    return
  }
  
  func willDisplayDetailForTaskByID(id: NSUUID?, forViewController controller: TaskDetailViewController) {
    detailViewController = controller
    var newID = id
    if id == nil {
      newID = taskRepository.defaultTask!.id
    }
    detailViewController!.date = selectedDate
    detailViewController!.period = selectedPeriod
    detailViewController!.previousTaskData = taskRepository.taskDetailForID(newID!)
    return
  }
  
  func willDisplaySplitViewFor(date: NSDate, period: Int) {
    selectedDate = date
    selectedPeriod = period
    let tasks = taskRepository.tasksForDateAndPeriod(date, period: period)
    tableViewController!.tasks = tasks
    tableViewController!.reload()
    return
  }
  
  func summariesForWeek() -> [TaskSummary] {
    let startDate = dateRepository.firstDate
    let stopDate = dateRepository.lastDate
    return taskRepository.taskSummariesForDatesBetween(startDate, stopDate: stopDate)
  }
  
  func didSetDateByIndex(index: Int, withData data: String) {
    dateRepository.setScheduleForDateByIndex(index, newSchedule: data)
  }
  
  func loadWeek(direction: Int) {
    if direction > 0 {
      dateRepository.loadNextWeek()
    } else {
      dateRepository.loadPreviousWeek()
    }
    summaryViewController!.taskSummaries = summariesForWeek()
    summaryViewController!.reloadCollectionView()
  }
  
  func missedClassesForDayByIndex(index: Int) -> [Int] {
    return dateRepository.missedClassesForDay(index)
  }
  
  func didDeleteTask(task: DailyTask) {
    taskRepository.deleteItem(task)
  }
  
  func willDisappear() {
    summaryViewController!.taskSummaries = summariesForWeek()
    summaryViewController!.reloadCollectionView()
  }
  

}
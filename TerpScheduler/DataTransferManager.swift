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
  func updateTask(task: DailyTask, withPreviousTask oldTask: DailyTask)
  var detailViewController: TaskDetailViewController? {get set}
  var defaultTask: DailyTask { get }
  func addItemToTableView()
}

protocol TaskTableDelegate {
  func willDisplayDetailForTask(task: DailyTask)
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
  func loadWeek(shouldFocusOnToday: Bool)
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
  var selectedTask: DailyTask?
  var detailViewController: TaskDetailViewController?
  var summaryViewController: MainViewController?
  var tableViewController: TaskTableViewController?
  var datesForWeek: [SchoolDate]{
    get { return dateRepository.dates }
  }
  var defaultTask: DailyTask {
    get { return taskRepository.defaultTask! }
  }
  
  
  func updateTask(task: DailyTask, withPreviousTask oldTask: DailyTask) {
    //let oldTask = tableViewController!.selectedTask
    if oldTask.period != 0{
      taskRepository.persistData(task, withMergeFromTask: oldTask)
    } else {
      taskRepository.persistData(task, withMergeFromTask: nil)
    }
    tableViewController!.reload()
    summaryViewController!.reloadCollectionView()
    return
  }
  
  func addItemToTableView() {
    tableViewController!.addAndSelectItem(defaultTask, forIndex: -1)
  }
  
  func willDisplayDetailForTask(task: DailyTask) {
    selectedTask = task
    detailViewController!.previousTaskData = selectedTask!
    detailViewController!.clear()
    summaryViewController!.performSegueWithIdentifier("ShowDetail", sender: self)
    summaryViewController?.splitViewController!.preferredDisplayMode = .AllVisible
    return
  }
  
  func willDisplaySplitViewFor(date: NSDate, period: Int) {
    selectedDate = date
    selectedPeriod = period
    let tasks = taskRepository.tasksForDateAndPeriod(date, period: period)
    tableViewController!.tasks = tasks
    tableViewController!.reload()
    if tasks.count > 0 {
      selectedTask = tasks[0]
      tableViewController!.addAndSelectItem(nil, forIndex: 0)
    } else {
      selectedTask = defaultTask
      tableViewController!.addAndSelectItem(selectedTask!, forIndex: -1)
    }
    detailViewController!.date = selectedDate
    detailViewController!.period = selectedPeriod
    detailViewController!.previousTaskData = selectedTask
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
  
  func loadWeek(shouldFocusOnToday: Bool) {
    let today = NSDate()
    dateRepository.loadWeekForDay(today)
    summaryViewController!.taskSummaries = summariesForWeek()
    summaryViewController!.reloadCollectionView()
  }
  
  func missedClassesForDayByIndex(index: Int) -> [Int] {
    return dateRepository.missedClassesForDay(index)
  }
  
  func didDeleteTask(task: DailyTask) {
    taskRepository.deleteItem(task)
    summaryViewController!.reloadCollectionView()
  }
  
  func willDisappear() {
    detailViewController!.navigationController!.popToRootViewControllerAnimated(true)
  }
  

}
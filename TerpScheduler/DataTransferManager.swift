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
  func didUpdateTitle(title: String)
}

protocol TaskTableDelegate {
  func willDisplayDetailForTask(task: DailyTask)
  var tableViewController: TaskTableViewController? { get set }
  var defaultTask: DailyTask { get }
  func didDeleteTask(task: DailyTask)
  func willDisappear()
}

protocol TaskSummaryDelegate {
  var isMiddleSchool: Bool { get }
  var shouldShadeStudyHall: Bool { get }
  var shouldDisplayExtraRow: Bool { get }
  func willDisplaySplitViewFor(date: NSDate, period: Int)
  func summariesForWeek()->[TaskSummary]
  var summaryViewController: MainViewController? { get set }
  var detailViewController: TaskDetailViewController? { get set }
}

protocol ExportDelegate {
  func getTasks(period: Int)->[DailyTask]
  func getTasks(weekID: Int, andExcludePeriods: [Int])->[DailyTask]
  func getClassInformation(period: Int)->SchoolClass
}

protocol DateInformationDelegate {
  var datesForWeek: [SchoolDate] { get }
  func didSetDateByIndex(index: Int, withData data: String)
  func loadWeek(direction: Int)
  func loadWeek(shouldFocusOnToday: Bool)
  func missedClassesForDayByIndex(index: Int)->[Int]
}

class DataManager: TaskDetailDelegate, TaskTableDelegate, TaskSummaryDelegate, ExportDelegate, DateInformationDelegate {
  init(){
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    defaults = appDelegate.userDefaults
    managedObjectContext = appDelegate.managedObjectContext!
    taskRepository = TaskRepository(context: managedObjectContext)
    dateRepository = DateRepository(context: managedObjectContext)
    schoolClassRepository = SchoolClassesRepository(context: managedObjectContext)
  }
  
  private var defaults: UserDefaults?
  private var managedObjectContext: NSManagedObjectContext
  private var taskRepository: TaskRepository
  private var dateRepository: DateRepository
  private var schoolClassRepository: SchoolClassesRepository
  private var selectedDate = NSDate()
  private var selectedPeriod = 1
  
  var isMiddleSchool: Bool {
    get {
      defaults!.readDefaults()
      return defaults!.isMiddleStudent
    }
  }
  
  var shouldShadeStudyHall: Bool {
    get {
      defaults!.readDefaults()
      return defaults!.shouldShadeStudyHall
    }
  }
  
  var shouldDisplayExtraRow: Bool {
    get {
      defaults!.readDefaults()
      return defaults!.shouldDisplayExtraRow
    }
  }
  
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
    if oldTask.period != -1 {
      taskRepository.persistData(task, withMergeFromTask: oldTask)
    } else {
     self.taskRepository.persistData(task, withMergeFromTask: nil)
    }
    if task.shouldNotify {
      postNotification(forTask: task)
    }
    tableViewController!.replaceItem(-1, withTask: task)
    tableViewController!.clearDirtyRows()
    summaryViewController!.reloadCollectionView()
    return
  }
  
  func addItemToTableView() {
    tableViewController!.addAndSelectItem(defaultTask, forIndex: -1)
  }
  
  func willDisplayDetailForTask(task: DailyTask) {
    selectedTask = task
    if detailViewController != nil {
      detailViewController!.clear()
      detailViewController!.previousTaskData = selectedTask!
      detailViewController!.setSubviewContentsFromTaskData(task)
    } else {
      summaryViewController!.performSegueWithIdentifier("ShowDetail", sender: self)
      summaryViewController?.splitViewController!.preferredDisplayMode = .AllVisible
    }
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
    if detailViewController!.delegate == nil {
      detailViewController!.delegate = self
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
    cancelNotificationMatching(task)
  }
  
  func willDisappear() {
    detailViewController!.navigationController!.popToRootViewControllerAnimated(true)
  }
  
  func didUpdateTitle(title: String){
    tableViewController!.updateTitleOfSelectedCell(title)
  }
  
  func getTasks(period: Int) -> [DailyTask]{
    let tasks = taskRepository.allTasksForPeriod(period)
    return tasks
  }
  
  func getTasks(weekID: Int, andExcludePeriods: [Int]) -> [DailyTask] {
    return [DailyTask]()
  }
  
  func getClassInformation(period: Int) -> SchoolClass {
    return schoolClassRepository.getClassDataByPeriod(period)
  }
  
  func postNotification(forTask task: DailyTask) {
    let notification = TaskNotification(task: task)
    let time = NotificationTimes.Afternoon
    notification.scheduleNotification(atTime: time)
  }
  
  func cancelNotificationMatching(task: DailyTask){
    for notification in UIApplication.sharedApplication().scheduledLocalNotifications as! [UILocalNotification] {
      if (notification.userInfo!["taskID"]! as! String == "\(task.shortTitle)\(task.period)") {
        UIApplication.sharedApplication().cancelLocalNotification(notification)
        break
      }
    }
  }

  
}

//
//  DataManager.swift
//  TerpScheduler
//
//  Created by Ben Hall on 1/21/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import UIKit
import CoreData

protocol TaskDetailDelegate: class {
  func updateTask(_ task: DailyTask, withPreviousTask oldTask: DailyTask)
  var detailViewController: TaskDetailViewController? {get set}
  var defaultTask: DailyTask { get }
  func addItemToTableView()
  func didUpdateTitle(_ title: String)
  func postNotification(forTask task: DailyTask)
  func cancelNotificationMatching(_ task: DailyTask)
}

protocol TaskTableDelegate: class {
  func willDisplayDetailForTask(_ task: DailyTask)
    func tasksFor(day: Date, period: Int) -> [DailyTask]
  var tableViewController: TaskTableViewController? { get set }
  var defaultTask: DailyTask { get }
  func didDeleteTask(_ task: DailyTask)
  func willDisappear()
  func addItemToTableView()
}

protocol TaskSummaryDelegate: class {
  var isMiddleSchool: Bool { get }
  var shouldShadeStudyHall: Bool { get }
  var shouldDisplayExtraRow: Bool { get }
    func willDisplaySplitViewFor(_ date: Date, period: Int, viewController: TaskEditViewController)
  func summariesForWeek() -> [TaskSummary]
  var summaryViewController: MainViewController? { get set }
  var detailViewController: TaskDetailViewController? { get set }
  func copyTasksFor(_ dateIndex: Int, period: Int)
  func pasteTasksTo(_ dateIndex: Int, period: Int)
  func deleteAllTasksFrom(_ dateIndex: Int, period: Int)
  func hasCopiedTasks() -> Bool
  func refreshDefaults()
}

protocol ExportDelegate: class {
  func getTasks(_ period: Int) -> [DailyTask]
  func getTasks(_ weekID: Int, andExcludePeriods: [Int]) -> [DailyTask]
  func getClassInformation(_ period: Int) -> SchoolClass
}

protocol DateInformationDelegate: class {
  var datesForWeek: [SchoolDate] { get }
  func didSetDateByIndex(_ index: Int, withData data: String)
  func loadWeek(_ direction: Int)
  func loadWeek(_ date: Date)
  func missedClassesForDayByIndex(_ index: Int) -> [Int]
  func didUpdateSchedulesForWeekInView()
  func dateBounds() -> (Date, Date)
}

class DataManager: TaskDetailDelegate, TaskTableDelegate, TaskSummaryDelegate, ExportDelegate, DateInformationDelegate {
  init(notificationHelper: NotificationManager) {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
      abort() //everything borked if not true
    }
    notificationManager = notificationHelper
    defaults = appDelegate.userDefaults
    managedObjectContext = appDelegate.managedObjectContext!
    taskRepository = TaskRepository(context: managedObjectContext)
    dateRepository = DateRepository(context: managedObjectContext)
    schoolClassRepository = SchoolClassesRepository(context: managedObjectContext)
  }

  fileprivate var notificationManager: NotificationManager
  fileprivate var defaults: CustomUserDefaults?
  fileprivate var managedObjectContext: NSManagedObjectContext
  fileprivate var taskRepository: TaskRepository
  fileprivate var dateRepository: DateRepository
  fileprivate var schoolClassRepository: SchoolClassesRepository
  fileprivate var selectedDate = Date()
  fileprivate var selectedPeriod = 1
  fileprivate var copiedTasks = [DailyTask]()

  var isMiddleSchool: Bool {
      defaults!.readDefaults()
      return defaults!.isMiddleStudent
  }

  var shouldShadeStudyHall: Bool {
      defaults!.readDefaults()
      return defaults!.shouldShadeStudyHall
  }

  var shouldDisplayExtraRow: Bool {
      defaults!.readDefaults()
      return defaults!.shouldDisplayExtraRow
  }

  var selectedTask: DailyTask?
  var detailViewController: TaskDetailViewController?
  var summaryViewController: MainViewController?
  var tableViewController: TaskTableViewController?
  var datesForWeek: [SchoolDate] {
    return dateRepository.dates
  }

  var defaultTask: DailyTask {
    return taskRepository.defaultTask!
  }

  func updateTask(_ task: DailyTask, withPreviousTask oldTask: DailyTask) {
    if oldTask.period != -1 {
      taskRepository.persistData(task, withMergeFromTask: oldTask)
    } else {
     self.taskRepository.persistData(task, withMergeFromTask: nil)
    }
    if task.shouldNotify {
      postNotification(forTask: task)
    }
    if task.isCompleted {
      cancelNotificationMatching(task)
    }
    tableViewController!.replaceItem(-1, withTask: task)
    tableViewController!.clearDirtyRows()
    summaryViewController!.reloadCollectionView()
    return
  }

  func addItemToTableView() {
    if detailViewController != nil {
      detailViewController!.saveData()
      detailViewController!.clear()
    }
    tableViewController!.addAndSelectItem(defaultTask, forIndex: -1)
  }

  func willDisplayDetailForTask(_ task: DailyTask) {
    if task != selectedTask! && detailViewController != nil {
      detailViewController!.saveData()
    }
    selectedTask = task
    if detailViewController != nil {
      detailViewController!.clear()
      detailViewController!.previousTaskData = selectedTask!
      detailViewController!.setSubviewContentsFromTaskData(task)
    } else {
      summaryViewController!.performSegue(withIdentifier: "ShowDetail", sender: self)
      summaryViewController?.splitViewController!.preferredDisplayMode = .allVisible
    }
    return
  }
    
    func tasksFor(day: Date, period: Int) -> [DailyTask] {
        return taskRepository.tasksForDateAndPeriod(day, period: period)
    }

    func willDisplaySplitViewFor(_ date: Date, period: Int, viewController: TaskEditViewController) {
    selectedDate = date
    selectedPeriod = period
    let tasks = taskRepository.tasksForDateAndPeriod(date, period: period)
    viewController.setData(date: date, period: period)
    
    return
  }
    
    func dateBounds() -> (Date, Date) {
        return (dateRepository.firstDateForYear, dateRepository.lastDateForYear);
    }

  func summariesForWeek() -> [TaskSummary] {
    let startDate = dateRepository.firstDate
    let stopDate = dateRepository.lastDate
    return taskRepository.taskSummariesForDatesBetween(startDate, stopDate: stopDate)
  }

  func didSetDateByIndex(_ index: Int, withData data: String) {
    dateRepository.setScheduleForDateByIndex(index, newSchedule: data)
  }
  
  func didUpdateSchedulesForWeekInView() {
    summaryViewController!.reloadCollectionView(true) //change shading
  }

  func loadWeek(_ direction: Int) {
    if direction > 0 {
      dateRepository.loadNextWeek()
    } else {
      dateRepository.loadPreviousWeek()
    }
    summaryViewController!.taskSummaries = summariesForWeek()
    summaryViewController!.reloadCollectionView()
  }

  func loadWeek(_ date: Date) {
    dateRepository.loadWeekForDay(date)
    summaryViewController!.taskSummaries = summariesForWeek()
    summaryViewController!.reloadCollectionView()
  }

  func missedClassesForDayByIndex(_ index: Int) -> [Int] {
    return dateRepository.missedClassesForDay(index)
  }

  func didDeleteTask(_ task: DailyTask) {
    taskRepository.deleteItem(task)
    summaryViewController?.reloadCollectionView()
    detailViewController?.clear()
    cancelNotificationMatching(task)
  }

  func willDisappear() {
    //detailViewController!.clear()
    detailViewController!.navigationController!.popToRootViewController(animated: true)
  }

  func didUpdateTitle(_ title: String) {
    tableViewController!.updateTitleOfSelectedCell(title)
  }

  func getTasks(_ period: Int) -> [DailyTask] {
    let tasks = taskRepository.allTasksForPeriod(period)
    return tasks
  }

  func getTasks(_ weekID: Int, andExcludePeriods: [Int]) -> [DailyTask] {
    return [DailyTask]()
  }

  func getClassInformation(_ period: Int) -> SchoolClass {
    return schoolClassRepository.getClassDataByPeriod(period)
  }

  func postNotification(forTask task: DailyTask) {
    guard defaults!.notificationPermissionGranted else { return }
    let notificationDate = self.notificationManager.getDateForNotification(task: task, time: defaults!.shouldNotifyWhen)
    self.notificationManager.scheduleNotification(task: task, date: notificationDate)
  }

  func cancelNotificationMatching(_ task: DailyTask) {
    self.notificationManager.cancelNotification(matching: task)
  }

  func copyTasksFor(_ dateIndex: Int, period: Int) {
    //note this overwrites what's in the "clipboard" space.
    let date = dateRepository.dates[dateIndex].Date
    copiedTasks = taskRepository.tasksForDateAndPeriod(date, period: period)
  }

  func pasteTasksTo(_ dateIndex: Int, period: Int) {
    if !hasCopiedTasks() {
      return
    }
    let date = dateRepository.dates[dateIndex].Date
    var newTasks = [DailyTask]()

    for task in copiedTasks {
      let newTask = DailyTask(date: date, period: period, shortTitle: task.shortTitle, details: task.details, isHaiku: task.isHaikuAssignment, completion: task.isCompleted, priority: task.priority, notify: task.shouldNotify)
      newTasks.append(newTask)
    }
    taskRepository.persistTasks(newTasks)
    summaryViewController!.reloadCollectionView()
  }

  func deleteAllTasksFrom(_ dateIndex: Int, period: Int) {
    let date = dateRepository.dates[dateIndex].Date
    for task in taskRepository.tasksForDateAndPeriod(date, period: period) {
      didDeleteTask(task)
    }
  }

  func hasCopiedTasks() -> Bool {
    return copiedTasks.count > 0
  }

  func refreshDefaults() {
    defaults!.readDefaults()
  }
}

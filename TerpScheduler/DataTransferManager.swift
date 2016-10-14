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
  func updateTask(_ task: DailyTask, withPreviousTask oldTask: DailyTask)
  var detailViewController: TaskDetailViewController? {get set}
  var defaultTask: DailyTask { get }
  func addItemToTableView()
  func didUpdateTitle(_ title: String)
  func postNotification(forTask task: DailyTask)
  func cancelNotificationMatching(_ task: DailyTask)
}

protocol TaskTableDelegate {
  func willDisplayDetailForTask(_ task: DailyTask)
  var tableViewController: TaskTableViewController? { get set }
  var defaultTask: DailyTask { get }
  func didDeleteTask(_ task: DailyTask)
  func willDisappear()
  func addItemToTableView()
}

protocol TaskSummaryDelegate {
  var isMiddleSchool: Bool { get }
  var shouldShadeStudyHall: Bool { get }
  var shouldDisplayExtraRow: Bool { get }
  func willDisplaySplitViewFor(_ date: Date, period: Int)
  func summariesForWeek()->[TaskSummary]
  var summaryViewController: MainViewController? { get set }
  var detailViewController: TaskDetailViewController? { get set }
  func copyTasksFor(_ dateIndex: Int, period: Int)
  func pasteTasksTo(_ dateIndex: Int, period: Int)
  func deleteAllTasksFrom(_ dateIndex: Int, period: Int)
  func hasCopiedTasks()->Bool
  func refreshDefaults()
}

protocol ExportDelegate {
  func getTasks(_ period: Int)->[DailyTask]
  func getTasks(_ weekID: Int, andExcludePeriods: [Int])->[DailyTask]
  func getClassInformation(_ period: Int)->SchoolClass
}

protocol DateInformationDelegate {
  var datesForWeek: [SchoolDate] { get }
  func didSetDateByIndex(_ index: Int, withData data: String)
  func loadWeek(_ direction: Int)
  func loadWeek(_ shouldFocusOnToday: Bool)
  func missedClassesForDayByIndex(_ index: Int)->[Int]
}

class DataManager: TaskDetailDelegate, TaskTableDelegate, TaskSummaryDelegate, ExportDelegate, DateInformationDelegate {
  init(){
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    defaults = appDelegate.userDefaults
    managedObjectContext = appDelegate.managedObjectContext!
    taskRepository = TaskRepository(context: managedObjectContext)
    dateRepository = DateRepository(context: managedObjectContext)
    schoolClassRepository = SchoolClassesRepository(context: managedObjectContext)
    backupManager = BackupManager(repository: taskRepository)
  }
  
  fileprivate var defaults: CustomUserDefaults?
  fileprivate var managedObjectContext: NSManagedObjectContext
  fileprivate var taskRepository: TaskRepository
  fileprivate var dateRepository: DateRepository
  fileprivate var schoolClassRepository: SchoolClassesRepository
  fileprivate var selectedDate = Date()
  fileprivate var selectedPeriod = 1
  fileprivate var copiedTasks = [DailyTask]()
  let backupManager: BackupManager
  
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
    if (detailViewController != nil){
      detailViewController!.saveData()
      detailViewController!.clear()
    }
    tableViewController!.addAndSelectItem(defaultTask, forIndex: -1)
    
  }
  
  func willDisplayDetailForTask(_ task: DailyTask) {
    if task != selectedTask! && detailViewController != nil{
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
  
  func willDisplaySplitViewFor(_ date: Date, period: Int) {
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
  
  func didSetDateByIndex(_ index: Int, withData data: String) {
    dateRepository.setScheduleForDateByIndex(index, newSchedule: data)
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
  
  func loadWeek(_ shouldFocusOnToday: Bool) {
    let today = Date()
    dateRepository.loadWeekForDay(today)
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
  
  func didUpdateTitle(_ title: String){
    tableViewController!.updateTitleOfSelectedCell(title)
  }
  
  func getTasks(_ period: Int) -> [DailyTask]{
    let tasks = taskRepository.allTasksForPeriod(period)
    return tasks
  }
  
  func getTasks(_ weekID: Int, andExcludePeriods: [Int]) -> [DailyTask] {
    return [DailyTask]()
  }
  
  func getClassInformation(_ period: Int) -> SchoolClass {
    return schoolClassRepository.getClassDataByPeriod(period)
  }
  
  fileprivate func notificationsEqual(_ n1: UILocalNotification, n2: UILocalNotification)->Bool
  {
    return n1.userInfo!["taskID"]! as! String == n2.userInfo!["taskID"]! as! String
  }
  
  func postNotification(forTask task: DailyTask) {
    let notification = TaskNotification(task: task)
    let time = defaults!.shouldNotifyWhen
    if UIApplication.shared.scheduledLocalNotifications!.contains(where: {$0.userInfo!["taskID"]! as! String == "\(task.shortTitle)\(task.period)"})
    {
      return //notification already exists
    }
    let _ = notification.scheduleNotification(atTime: time)
  }
  
  func cancelNotificationMatching(_ task: DailyTask){
    for notification in UIApplication.shared.scheduledLocalNotifications! {
      if (notification.userInfo!["taskID"]! as! String == "\(task.shortTitle)\(task.period)") {
        UIApplication.shared.cancelLocalNotification(notification)
        break
      }
    }
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
  
  func hasCopiedTasks()->Bool{
    return copiedTasks.count > 0
  }
  
  func refreshDefaults() {
    defaults!.readDefaults()
  }

  
}

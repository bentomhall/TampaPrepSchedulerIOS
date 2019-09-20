//
//  DataManager.swift
//  TerpScheduler
//
//  Created by Ben Hall on 1/21/15.
//  Copyright (c) 2019 Tampa Preparatory School. All rights reserved.
//

import UIKit
import CoreData

protocol TaskDetailDelegate: class {
    func updateTask(_ task: DailyTask, withPreviousTask oldTask: DailyTask) -> DailyTask
    var defaultTask: DailyTask { get }
    func postNotification(forTask task: DailyTask)
    func cancelNotificationMatching(_ task: DailyTask)
}

protocol TaskTableDelegate: class {
    func tasksFor(day: Date, period: Int) -> [DailyTask]
    var defaultTask: DailyTask { get }
    func didDeleteTask(_ task: DailyTask)
}

protocol TaskSummaryDelegate: class {
    var isMiddleSchool: Bool { get }
    var shouldShadeStudyHall: Bool { get }
    var shouldDisplayExtraRow: Bool { get }
    func willDisplaySplitViewFor(_ date: Date, period: Int, viewController: TaskEditViewController)
    func summariesForWeek() -> [TaskSummary]
    var summaryViewController: MainViewController? { get set }
    func copyTasksFor(_ dateIndex: Int, period: Int)
    func pasteTasksTo(_ dateIndex: Int, period: Int)
    func deleteAllTasksFrom(_ dateIndex: Int, period: Int)
    func hasCopiedTasks() -> Bool
    func refreshDefaults()
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

/// Main "God Class" for data transfer. Basically everything talks to this. Yes, it should get sliced-and-diced and repackaged for individual needs. But...not right now.
class DataManager: TaskDetailDelegate, TaskTableDelegate, TaskSummaryDelegate, DateInformationDelegate {
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
    
    fileprivate var selectedTask: DailyTask?
    
    /// Mark: DateInformationDelegate
    
    var datesForWeek: [SchoolDate] {
        return dateRepository.dates
    }
    
    func dateBounds() -> (Date, Date) {
        return (dateRepository.firstDateForYear, dateRepository.lastDateForYear);
    }
    
    func didSetDateByIndex(_ index: Int, withData data: String) {
        dateRepository.setScheduleForDateByIndex(index, newSchedule: data)
    }
    
    func didUpdateSchedulesForWeekInView() {
        summaryViewController!.reloadCollectionView(true) //change shading
    }
    
    /// Handles changing the week.
    ///
    /// - Parameter direction: +1 or -1, although only sign matters. Positive -> next week.
    func loadWeek(_ direction: Int) {
        if direction > 0 {
            dateRepository.loadNextWeek()
        } else {
            dateRepository.loadPreviousWeek()
        }
        summaryViewController!.taskSummaries = summariesForWeek()
        summaryViewController!.reloadCollectionView()
    }
    
    /// Moves the week in view to the week containing the chosen date.
    ///
    /// - Parameter date: Date to center on.
    func loadWeek(_ date: Date) {
        dateRepository.loadWeekForDay(date)
        summaryViewController!.taskSummaries = summariesForWeek()
        summaryViewController!.reloadCollectionView()
    }
    
    func missedClassesForDayByIndex(_ index: Int) -> [Int] {
        return dateRepository.missedClassesForDay(index)
    }
    
    /// Mark: TaskTableDelegate
    
    func didDeleteTask(_ task: DailyTask) {
        taskRepository.deleteItem(task)
        summaryViewController?.reloadCollectionView()
        cancelNotificationMatching(task)
    }
    
    func tasksFor(day: Date, period: Int) -> [DailyTask] {
        return taskRepository.tasksForDateAndPeriod(day, period: period)
    }
    
    func getClassInformation(_ period: Int) -> SchoolClass {
        return schoolClassRepository.getClassDataByPeriod(period)
    }
    
    /// Mark: TaskDetailDelegate Compliance
    
    var defaultTask: DailyTask {
        return taskRepository.defaultTask!
    }
    
    func updateTask(_ task: DailyTask, withPreviousTask oldTask: DailyTask) -> DailyTask {
        var updatedTask : DailyTask
        if oldTask.period != -1 {
            updatedTask = taskRepository.persistData(task, withMergeFromTask: oldTask)
        } else {
            updatedTask = self.taskRepository.persistData(task, withMergeFromTask: nil)
        }
        if task.shouldNotify {
            postNotification(forTask: task)
        }
        if task.isCompleted {
            cancelNotificationMatching(task)
        }
        return updatedTask
    }
    
    func postNotification(forTask task: DailyTask) {
        guard defaults!.notificationPermissionGranted else { return }
        let notificationDate = self.notificationManager.getDateForNotification(task: task, time: defaults!.shouldNotifyWhen)
        self.notificationManager.scheduleNotification(task: task, date: notificationDate)
    }
    
    func cancelNotificationMatching(_ task: DailyTask) {
        self.notificationManager.cancelNotification(matching: task)
    }
    
    /// Mark: TaskSummaryDelegate Compliance
    
    /// A reference to the controller handling the main display. Probably a bad idea, but...
    var summaryViewController: MainViewController?
    
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
    
    
    /// Required for protocol compliance, but unused. Was used in previous version.
    ///
    /// - Parameters:
    ///   - date: the date of the task
    ///   - period: the class period of the task.
    ///   - viewController: The controller handling the editing.
    @available(*, deprecated)
    func willDisplaySplitViewFor(_ date: Date, period: Int, viewController: TaskEditViewController) {
        selectedDate = date
        selectedPeriod = period
        viewController.setData(date: date, period: period)
        return
    }
    
    func summariesForWeek() -> [TaskSummary] {
        let startDate = dateRepository.firstDate
        let stopDate = dateRepository.lastDate
        return taskRepository.taskSummariesForDatesBetween(startDate, stopDate: stopDate)
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
            let newTask = DailyTask(date: date, period: period, shortTitle: task.shortTitle, details: task.details, isHaiku: task.isHaikuAssignment, completion: task.isCompleted, priority: task.priority, notify: task.shouldNotify, guid: task.GUID)
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

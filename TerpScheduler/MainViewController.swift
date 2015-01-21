//
//  ViewController.swift
//  TerpScheduler
//
//  Created by Ben Hall on 12/18/14.
//  Copyright (c) 2014 Tampa Preparatory School. All rights reserved.
//
import CoreData
import Foundation
import UIKit

@IBDesignable
class MainViewController: UIViewController {
  
  var appDelegate : AppDelegate?
  var context : NSManagedObjectContext?
  var tableDelegate : TaskDataDelegate?
  @IBOutlet weak var collectionView : UICollectionView?
  @IBOutlet var classPeriods : [SchoolClassView]?
  @IBAction func SwipeRecognizer(recognizer: UISwipeGestureRecognizer){
    let direction = recognizer.direction
    switch (direction)
    {
      case UISwipeGestureRecognizerDirection.Right:
        dateRepository!.LoadPreviousWeek()
        getTaskSummariesForDatesBetween(dateRepository!.firstDate, stopDate: dateRepository!.lastDate)
        reloadCollectionView()
        break
      case UISwipeGestureRecognizerDirection.Left:
        dateRepository!.LoadNextWeek()
        getTaskSummariesForDatesBetween(dateRepository!.firstDate, stopDate: dateRepository!.lastDate)
        reloadCollectionView()
        break
      default:
        //do nothing
        break
    }
  }
  
  var taskSummaries : [TaskSummaryData]?
  var taskRepository: TaskCollectionRepository?
  var dateRepository: DateHeaderRepository?
  var classRepository: SchoolClassesRepository?
  
  var detailIndex: (day: Int, period: Int) = (0,0)
  var dataForSelectedTask: DailyTaskData?
  
  func getTaskSummariesForDatesBetween(startDate: NSDate, stopDate: NSDate){
    taskSummaries = taskRepository!.taskSummariesForDates(startDate, stopDate: stopDate)
  }
  
  func dayAndPeriodFromIndexPath(row: Int)->(day: Int, period: Int){
    let days = 5
    let dayIndex = row % days
    let periodIndex = Int(Double(row)/Double(days)) + 1 //ugly
    return (day: dayIndex, period: periodIndex)
  }
  
  //Mark - Overrides
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
    context = appDelegate!.managedObjectContext
    taskRepository = TaskCollectionRepository(context: context!)
    dateRepository = DateHeaderRepository(context: context!)
    classRepository = SchoolClassesRepository(appDelegate: appDelegate!)
    getTaskSummariesForDatesBetween(dateRepository!.firstDate, stopDate: dateRepository!.lastDate)
    let tableView = splitViewController!.view.viewWithTag(1) as UITableView
    if let ds = tableView.dataSource as? TaskTableViewController{
      tableDelegate = ds
      ds.repository = taskRepository
    }
  }
  
  override func viewDidAppear(animated: Bool) {
    for (index, period) in enumerate(classPeriods!){
      let classData = classRepository!.GetClassDataByPeriod(index + 1)
      period.classData = classData
    }
    self.splitViewController!.preferredDisplayMode = UISplitViewControllerDisplayMode.PrimaryHidden
    super.viewDidAppear(animated)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier!.hasPrefix("ClassDetail") {
      let index = segue.identifier!.componentsSeparatedByString("_")[1].toInt()
      var receivingController = segue.destinationViewController as ClassPeriodViewController
      receivingController.modalPresentationStyle = .Popover
      receivingController.preferredContentSize = CGSize(width: 300, height: 300)
      receivingController.delegate = self
      receivingController.index = index!
    } else if segue.identifier!.hasPrefix("Day"){
      let index = segue.identifier!.componentsSeparatedByString("_")[1].toInt()
      var receivingController = segue.destinationViewController as ScheduleOverrideController
      receivingController.modalPresentationStyle = .Popover
      receivingController.preferredContentSize = CGSize(width: 500, height: 200)
      receivingController.delegate = self
      receivingController.index = index!
      receivingController.date = dateRepository!.dateStringByIndex(index!)
      receivingController.previousSchedule = dateRepository!.ScheduleForDateByIndex(index!)
    } else if segue.identifier! == "TaskDetail"{
      var receivingController = segue.destinationViewController as TaskDetailViewController
      receivingController.delegate = self
      dataForSelectedTask = tableDelegate!.getSelected()
      receivingController.previousTaskData = dataForSelectedTask
    }
    super.prepareForSegue(segue, sender: sender)
  }
}

//MARK - UICollectionViewDelegate
extension MainViewController: UICollectionViewDelegate {
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    detailIndex = dayAndPeriodFromIndexPath(indexPath.row)
    self.splitViewController!.preferredDisplayMode = UISplitViewControllerDisplayMode.AllVisible
      let tableView = splitViewController!.view.viewWithTag(1) as UITableView
      if let ds = tableView.dataSource as? TaskTableViewController{
        let date = dateRepository!.dates[detailIndex.day].Date
        let period = detailIndex.period
        ds.loadTasks(date, andPeriod: period)
        tableView.reloadData()
      }
  }
}

//MARK - UICollectionViewDataSource
extension MainViewController: UICollectionViewDataSource {
  func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 35
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    var cell = self.collectionView!.dequeueReusableCellWithReuseIdentifier("ClassPeriodTaskSummary", forIndexPath: indexPath) as DailyTaskSmallView
    cell.backgroundColor = UIColor.whiteColor()
    let selectedDayIndexes = dayAndPeriodFromIndexPath(indexPath.row)
    if let missedClasses = dateRepository!.missedClassesForDay(selectedDayIndexes.day){
      if contains(missedClasses, selectedDayIndexes.period){
        cell.backgroundColor = UIColor.lightGrayColor()
      }
    }
    let summary = taskSummaries![indexPath.row]// hack [indexPath.row]
    cell.setTopTaskLabel(summary.shortTitle)
    cell.setRemainingTasksLabel(summary.remainingTasks)
    return cell
  }
  
  func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
    var header = self.collectionView?.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "dateHeaderBlock", forIndexPath: indexPath) as DateHeaderView
    header.SetDates(dateRepository!.dates)
    return header
  }
  
  func reloadCollectionView(){
    collectionView!.reloadData()
  }
}

//MARK - ClassPeriodDataSource compliance
extension MainViewController: ClassPeriodDataSource {
  func setClassData(data: ClassPeriodData, forIndex index:Int){
    classPeriods![index].classData = data
    classRepository!.SetClassModelFromData(data)
  }
  
  func getClassData(period: Int)->ClassPeriodData{
    return classPeriods![period].classData
  }
}

extension MainViewController: ScheduleOverrideDelegate{
  func updateScheduleForIndex(index: Int, withSchedule schedule: String){
    dateRepository!.setScheduleForDateByIndex(index, newSchedule: schedule)
    reloadCollectionView()
  }
}

extension MainViewController: TaskDetailDelegate{
  func updateTaskData(data: DailyTaskData) {
    tableDelegate!.addTask(data)
    getTaskSummariesForDatesBetween(dateRepository!.firstDate, stopDate: dateRepository!.lastDate)
    reloadCollectionView()
    tableDelegate!.reload()
  }
  
  var nextID: Int {
    get { return tableDelegate!.nextID }
  }
}




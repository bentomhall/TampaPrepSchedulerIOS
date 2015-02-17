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

protocol PopOverPresentable {
  var delegate: AnyObject { get set }
  var preferredContentSize: CGSize { get set }
  var modalPresentationStyle: UIModalPresentationStyle { get set }
  var index: Int { get set }
}

@IBDesignable
class MainViewController: UIViewController {
  
  private var appDelegate : AppDelegate?
  var delegate: TaskSummaryDelegate?
  @IBOutlet weak var collectionView : UICollectionView?
  @IBOutlet var classPeriods : [SchoolClassView]?
  @IBAction func SwipeRecognizer(recognizer: UISwipeGestureRecognizer){
    let direction = recognizer.direction
    switch (direction)
    {
      case UISwipeGestureRecognizerDirection.Right:
        delegate!.loadWeek(-1)
        break
      case UISwipeGestureRecognizerDirection.Left:
        delegate!.loadWeek(1)
        break
      default:
        //do nothing
        break
    }
  }
  
  @IBAction func TodayButtonTapped(sender: UIButton){
    delegate!.loadWeek(true)
  }
  
  var taskSummaries : [TaskSummary]?
  var classRepository: SchoolClassesRepository?
  
  var detailIndex: (day: Int, period: Int) = (0,0)
  var dataForSelectedTask: DailyTask?
  private var lockedClasses = [Int]()
  
  
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
    classRepository = SchoolClassesRepository(context: appDelegate!.managedObjectContext!)
    delegate = appDelegate!.dataManager
    delegate!.summaryViewController = self
    taskSummaries = delegate!.summariesForWeek()
  }
  
  override func viewDidAppear(animated: Bool) {
    for (index, period) in enumerate(classPeriods!){
      let classData = classRepository!.GetClassDataByPeriod(index + 1)
      period.classData = classData
    }
    self.splitViewController!.preferredDisplayMode = UISplitViewControllerDisplayMode.PrimaryHidden
    self.navigationController?.setNavigationBarHidden(false, animated: false)
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
      receivingController.delegate = self
      receivingController.index = index!
      let dateInformation = delegate!.datesForWeek[index!]
      receivingController.previousSchedule = dateInformation.Schedule
    } else if segue.identifier! == "WebView"{
      let url = sender as NSURL
      let receivingController = segue.destinationViewController as WebViewController
      receivingController.initialURL = url
    } else if segue.identifier! == "ShowDetail" || segue.identifier! == "ReplaceDetail"{
      let receivingController = segue.destinationViewController as TaskDetailViewController
      if let sender = sender as? DataManager{
        receivingController.previousTaskData = sender.selectedTask
      }
      delegate!.detailViewController = receivingController
    }
    
    super.prepareForSegue(segue, sender: sender)
  }
  
  override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    let width = size.width - CGFloat(130.0)
    collectionView!.collectionViewLayout.invalidateLayout()
  }
  
  func showDetail(task: DailyTask){
    self.performSegueWithIdentifier("ReplaceDetail", sender: self)
  }
}

//MARK - UICollectionViewDelegate
extension MainViewController: UICollectionViewDelegate {
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    detailIndex = dayAndPeriodFromIndexPath(indexPath.row)
    let date = delegate!.datesForWeek[detailIndex.day].Date
    delegate!.willDisplaySplitViewFor(date, period: detailIndex.period)
    self.splitViewController!.preferredDisplayMode = UISplitViewControllerDisplayMode.AllVisible
  }
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    if UIInterfaceOrientationIsPortrait(self.interfaceOrientation) {
      //portrait
      return CGSize(width: 114, height: 116)
    } else {
      //landscape
      return CGSize(width: 166, height: 116)
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
    if let missedClasses = delegate?.missedClassesForDayByIndex(selectedDayIndexes.day){
      if contains(missedClasses, selectedDayIndexes.period){
        cell.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.1)
      }
    }
    let summary = taskSummaries![indexPath.row]
    cell.setTopTaskLabel(summary.title, isTaskCompleted: summary.completion)
    cell.setRemainingTasksLabel(summary.remainingTasks)
    return cell
  }
  
  func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
    var header = self.collectionView?.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "dateHeaderBlock", forIndexPath: indexPath) as DateHeaderView
    header.SetDates(delegate!.datesForWeek)
    return header
  }
  
  func reloadCollectionView(){
    taskSummaries = delegate!.summariesForWeek()
    collectionView!.reloadData()
  }
  
}

//MARK - ClassPeriodDataSource compliance
extension MainViewController: ClassPeriodDataSource {
  func setClassData(data: SchoolClass, forIndex index:Int){
    classPeriods![index].classData = data
    classRepository!.persistData(data)
  }
  
  func getClassData(period: Int)->SchoolClass{
    return classPeriods![period].classData
  }
  
  func openWebView(url: NSURL) {
    performSegueWithIdentifier("WebView", sender: url)
  }
}

extension MainViewController: ScheduleOverrideDelegate{
  func updateScheduleForIndex(index: Int, withSchedule schedule: String){
    delegate!.didSetDateByIndex(index, withData: schedule)
    reloadCollectionView()
  }
}




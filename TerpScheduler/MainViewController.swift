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
  
  private let noClassColor = UIColor(white: 0, alpha: 0.1)
  private var shadedRowIndexes = [0:false, 1:false, 2:false, 3:false, 4:false, 5:false, 6:false, 7:false]
  private var appDelegate : AppDelegate?
  var delegate: TaskSummaryDelegate?
  private var contentOffset = CGPointZero
  
  @IBOutlet weak var contentView: UIView?
  @IBOutlet weak var scrollView: UIScrollView?
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
  
  func dayAndPeriodFromIndexPath(row: Int)->(day: Int, period: Int){
    let days = 5
    let dayIndex = row % days
    let periodIndex = Int(Double(row)/Double(days)) //ugly
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
    self.splitViewController!.preferredDisplayMode = UISplitViewControllerDisplayMode.PrimaryHidden
    splitViewController!.presentsWithGesture = false
    scrollView!.setTranslatesAutoresizingMaskIntoConstraints(false)
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    scrollView!.contentSize = CGSizeMake(contentView!.frame.width, contentView!.frame.height)
  }
  
  override func viewDidAppear(animated: Bool) {
    for (index, period) in enumerate(classPeriods!){
      let classData = classRepository!.getClassDataByPeriod(index)
      period.classData = classData
      if classData.isStudyHall {
        shouldShadeRow(true, forPeriod: index)
      }
    }
    self.navigationController?.setNavigationBarHidden(false, animated: false)
    scrollView?.delegate = self
    //scrollView!.setContentOffset(contentOffset, animated: false)
    super.viewDidAppear(animated)
  }
  
  override func viewWillDisappear(animated: Bool) {
    scrollView!.delegate = nil
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
      receivingController.preferredContentSize = CGSize(width: 500, height: 300)
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
    //contentOffset = scrollView!.contentOffset
    super.prepareForSegue(segue, sender: sender)
  }
  
  override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    collectionView!.collectionViewLayout.invalidateLayout()
    scrollView!.contentSize = CGSizeMake(size.width, collectionView!.frame.height)
    /*
    if size.width > 768 {
      //landscape
      scrollView!.contentSize = CGSizeMake(size.width, collectionView!.frame.height)
    } else {
      scrollView!.contentSize = CGSizeMake(size.width, collectionView!.frame.height)
    }
*/
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
      return CGSize(width: 117, height: 116)
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
    return 40
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    var cell = self.collectionView!.dequeueReusableCellWithReuseIdentifier("ClassPeriodTaskSummary", forIndexPath: indexPath) as DailyTaskSmallView
    var shadingType: CellShadingType
    let selectedDayIndexes = dayAndPeriodFromIndexPath(indexPath.row)
    if (shadedRowIndexes[selectedDayIndexes.period]! && delegate!.shouldShadeStudyHall){
      shadingType = .studyHall
    } else if (selectedDayIndexes.period == 7 && delegate!.isMiddleSchool){
      shadingType = .noClass
    } else {
      shadingType = .noShading
    }
    if let missedClasses = delegate?.missedClassesForDayByIndex(selectedDayIndexes.day){
      if contains(missedClasses, selectedDayIndexes.period){
        shadingType = .noClass
      }
    }
    cell.shouldShadeCell(shadingType)
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
    if data.isStudyHall {
      shouldShadeRow(true, forPeriod: index+1)
    } else {
      shouldShadeRow(false, forPeriod: index+1)
    }
    classRepository!.persistData(data)
  }
  
  func getClassData(period: Int)->SchoolClass{
    return classPeriods![period].classData
  }
  
  func openWebView(url: NSURL) {
    performSegueWithIdentifier("WebView", sender: url)
  }
  
  func setCellColor(index: Int, toColor color: UIColor){
    for indx in 0...4 {
      let row = indx + (index-1)*5
      let cell = collectionView!.cellForItemAtIndexPath(NSIndexPath(forItem: row, inSection: 0))
      cell!.backgroundColor = color
    }
  }
  
  func shouldShadeRow(value: Bool, forPeriod: Int) {
    let oldValue = shadedRowIndexes[forPeriod]!
    if value != oldValue {
      shadedRowIndexes[forPeriod] = value
      reloadCollectionView()
    }
  }
}

extension MainViewController: ScheduleOverrideDelegate{
  func updateScheduleForIndex(index: Int, withSchedule schedule: String){
    delegate!.didSetDateByIndex(index, withData: schedule)
    reloadCollectionView()
  }
}

extension MainViewController: UIScrollViewDelegate {
  func scrollViewDidScroll(scrollView: UIScrollView) {
    //NSLog("%@", NSStringFromCGSize(scrollView.contentSize))
    //if scrollView.contentOffset.y < 0 {
    //  scrollView.setContentOffset(CGPointZero, animated: false)
    //}
    //if UIInterfaceOrientationIsPortrait(self.interfaceOrientation){
    //  scrollView.setContentOffset(CGPointZero, animated: false) //disallow scrolling
    //} else {
      //if scrollView.contentOffset.y > 250 {
      //  scrollView.setContentOffset(CGPointMake(0, 250), animated: false)
      //}
    //}
  }
}





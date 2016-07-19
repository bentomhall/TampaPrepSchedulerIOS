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
  
  private var shadedRowIndexes = [1:false, 2:false, 3:false, 4:false, 5:false, 6:false, 7:false, 8:false]
  private var appDelegate : AppDelegate?
  var delegate: protocol<TaskSummaryDelegate, DateInformationDelegate>?
  private var contentOffset = CGPointZero
  private var deviceOrientationisPortrait = false
  
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
    let periodIndex = Int(Double(row)/Double(days)) + 1 //ugly
    return (day: dayIndex, period: periodIndex)
  }
  
  //Mark - Overrides
  override func viewDidLoad() {
    super.viewDidLoad()
    appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
    classRepository = SchoolClassesRepository(context: appDelegate!.managedObjectContext!)
    delegate = appDelegate!.dataManager
    delegate!.summaryViewController = self
    taskSummaries = delegate!.summariesForWeek()
    self.splitViewController!.preferredDisplayMode = UISplitViewControllerDisplayMode.PrimaryHidden
    splitViewController!.presentsWithGesture = false
    scrollView!.translatesAutoresizingMaskIntoConstraints = false
    deviceOrientationisPortrait = appDelegate!.window!.bounds.height > appDelegate!.window!.bounds.width
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(onDefaultsChanged), name: NSUserDefaultsDidChangeNotification, object: nil)
    
  }
  
  func onDefaultsChanged(notification: NSNotification){
    delegate!.refreshDefaults()
    reloadCollectionView()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    scrollView!.contentSize = CGSizeMake(contentView!.frame.width, contentView!.frame.height)
  }
  
  override func viewDidAppear(animated: Bool) {
    performShading()
    self.navigationController?.setNavigationBarHidden(false, animated: false)
    scrollView?.delegate = self
    super.viewDidAppear(animated)
  }
  
  func performShading(){
    for (index, period) in (classPeriods!).enumerate(){
      var classData: SchoolClass
      if delegate!.isMiddleSchool && index == 6{
        classData = classRepository!.getMiddleSchoolSports()
      } else {
        classData = classRepository!.getClassDataByPeriod(index)
      }
      period.classData = classData
      if classData.isStudyHall {
        shouldShadeRow(delegate!.shouldShadeStudyHall, forPeriod: index+1)
      }
    }
  }
  
  override func viewWillDisappear(animated: Bool) {
    scrollView!.delegate = nil
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier!.hasPrefix("ClassDetail") {
      let index = Int(segue.identifier!.componentsSeparatedByString("_")[1])
      let receivingController = segue.destinationViewController as! ClassPeriodViewController
      receivingController.modalPresentationStyle = .Popover
      receivingController.preferredContentSize = CGSize(width: 500, height: 260)
      receivingController.delegate = self
      receivingController.index = index!
    } else if segue.identifier!.hasPrefix("Day"){
      let index = Int(segue.identifier!.componentsSeparatedByString("_")[1])
      let receivingController = segue.destinationViewController as! ScheduleOverrideController
      receivingController.modalPresentationStyle = .Popover
      receivingController.delegate = self
      receivingController.index = index!
      let dateInformation = delegate!.datesForWeek[index!]
      receivingController.previousSchedule = dateInformation.Schedule
    } else if segue.identifier! == "WebView"{
      let url = sender as! NSURL
      let receivingController = segue.destinationViewController as! WebViewController
      receivingController.initialURL = url
    } else if segue.identifier! == "ShowDetail" || segue.identifier! == "ReplaceDetail"{
      let receivingController = segue.destinationViewController as! TaskDetailViewController
      delegate!.detailViewController = receivingController
    }
    super.prepareForSegue(segue, sender: sender)
  }
  
  override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    coordinator.animateAlongsideTransition(nil, completion: {(context:UIViewControllerTransitionCoordinatorContext!)->Void in
      self.deviceOrientationisPortrait = size.width < size.height
      self.collectionView!.collectionViewLayout.invalidateLayout()
      self.scrollView!.contentSize = CGSizeMake(size.width, self.collectionView!.frame.height)
      return
    })
  }
  
  func showDetail(task: DailyTask){
    self.performSegueWithIdentifier("ReplaceDetail", sender: self)
  }
  
  func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer){
    if gestureRecognizer.state != UIGestureRecognizerState.Ended {
      return
    }
    let p = gestureRecognizer.locationInView(self.collectionView)
    let indexPath = self.collectionView?.indexPathForItemAtPoint(p)
    
    if indexPath != nil {
      let menuController = UIMenuController.sharedMenuController()
      let selectionRectangle = CGRectMake(p.x, p.y, 100, 100)
      menuController.setTargetRect(selectionRectangle, inView: self.collectionView!)
      menuController.setMenuVisible(true, animated: true)
    }
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
  
  func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
  }
  
  func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
    if action == #selector(cut){
      return true
    } else if action == #selector(NSObject.copy(_:)){
      return true
    } else if action == #selector(NSObject.paste(_:)){
      return delegate!.hasCopiedTasks()
    } else {
      return false
    }
  }
  
  func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    //WARN Incomplete implementation
    let dayAndPeriod = dayAndPeriodFromIndexPath(indexPath.row)
    if action == #selector(NSObject.copy(_:)){
      delegate!.copyTasksFor(dayAndPeriod.day, period: dayAndPeriod.period)
    } else if action == #selector(NSObject.paste(_:)){
      delegate!.pasteTasksTo(dayAndPeriod.day, period: dayAndPeriod.period)
    } else if action == #selector(NSObject.cut(_:)){
      delegate!.copyTasksFor(dayAndPeriod.day, period: dayAndPeriod.period)
      delegate!.deleteAllTasksFrom(dayAndPeriod.day, period: dayAndPeriod.period)
    }
    return
  }
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    if deviceOrientationisPortrait {
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
    if delegate!.shouldDisplayExtraRow {
      return 40
    } else {
      return 35
    }
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = self.collectionView!.dequeueReusableCellWithReuseIdentifier("ClassPeriodTaskSummary", forIndexPath: indexPath) as! DailyTaskSmallView
    var shadingType: CellShadingType = .noShading
    let selectedDayIndexes = dayAndPeriodFromIndexPath(indexPath.row)
    if delegate!.isMiddleSchool && (selectedDayIndexes.period == 7){
      shadingType = .noShading
    } else if (shadedRowIndexes[selectedDayIndexes.period]! && delegate!.shouldShadeStudyHall){
      shadingType = .studyHall
    } else if let missedClasses = delegate?.missedClassesForDayByIndex(selectedDayIndexes.day){
      if missedClasses.contains(selectedDayIndexes.period){
        shadingType = .noClass
      }
    }
    cell.shouldShadeCell(shadingType)
    let summary = taskSummaries![indexPath.row]
    cell.setTopTaskLabel(summary.title, isTaskCompleted: summary.completion)
    cell.setRemainingTasksLabel(tasksRemaining: summary.remainingTasks)
    return cell
  }
  
  func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
    let header = self.collectionView?.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "dateHeaderBlock", forIndexPath: indexPath) as! DateHeaderView
    header.SetDates(delegate!.datesForWeek)
    return header
  }
  
  func reloadCollectionView(){
    taskSummaries = delegate!.summariesForWeek()
    performShading()
    collectionView!.reloadData()
  }
}

//MARK - ClassPeriodDataSource compliance
extension MainViewController: ClassPeriodDataSource {
  func setClassData(data: SchoolClass, forIndex index:Int){
    classPeriods![index].classData = data
    if data.isStudyHall {
      shouldShadeRow(true, forPeriod: index + 1) //period indexes start at 1
    } else {
      shouldShadeRow(false, forPeriod: index + 1)
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

extension MainViewController: UIGestureRecognizerDelegate{
  func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOfGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
}


//extension MainViewController: UIScrollViewDelegate {
//  func scrollViewDidScroll(scrollView: UIScrollView) {
//  }
//}





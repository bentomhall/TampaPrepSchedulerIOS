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

  fileprivate var shadedRowIndexes = [1: false, 2: false, 3: false, 4: false, 5: false, 6: false, 7: false, 8: false]
    fileprivate weak var appDelegate: AppDelegate?
    /// The main "god object" reference.
  weak var delegate: (TaskSummaryDelegate & DateInformationDelegate)?
  fileprivate var contentOffset = CGPoint.zero
  fileprivate var deviceOrientationisPortrait = false
  fileprivate var colors: UserColors?

  @IBOutlet weak var contentView: UIView?
  @IBOutlet weak var scrollView: UIScrollView?
  @IBOutlet weak var collectionView: UICollectionView?
  @IBOutlet var classPeriods: [SchoolClassView]?
  @IBAction func SwipeRecognizer(_ recognizer: UISwipeGestureRecognizer) {
    let direction = recognizer.direction
    switch direction {
      case UISwipeGestureRecognizer.Direction.right:
        delegate!.loadWeek(-1)
        break
      case UISwipeGestureRecognizer.Direction.left:
        delegate!.loadWeek(1)
        break
      default:
        //do nothing
        break
    }
  }

  @IBAction func TodayButtonTapped(_ sender: UIButton) {
    let today = Date()
    delegate!.loadWeek(today)
  }

  var taskSummaries: [TaskSummary]?
  var classRepository: SchoolClassesRepository?
  var detailIndex: (day: Int, period: Int) = (0, 0)
  var dataForSelectedTask: DailyTask?

  func dayAndPeriodFromIndexPath(_ row: Int) -> (day: Int, period: Int) {
    let days = 5
    let dayIndex = row % days
    let periodIndex = Int(Double(row)/Double(days)) + 1 //ugly
    return (day: dayIndex, period: periodIndex)
  }

  //Mark - Overrides
  override func viewDidLoad() {
    super.viewDidLoad()
    appDelegate = UIApplication.shared.delegate as? AppDelegate
    colors = appDelegate!.userColors
    classRepository = SchoolClassesRepository(context: appDelegate!.managedObjectContext!)
    delegate = appDelegate!.dataManager
    delegate!.summaryViewController = self
    taskSummaries = delegate!.summariesForWeek()
    scrollView!.translatesAutoresizingMaskIntoConstraints = false
    deviceOrientationisPortrait = appDelegate!.window!.bounds.height > appDelegate!.window!.bounds.width

    NotificationCenter.default.addObserver(self, selector: #selector(onDefaultsChanged), name: UserDefaults.didChangeNotification, object: nil)
  }

  @objc func onDefaultsChanged(_ notification: Notification) {
    delegate!.refreshDefaults()
    reloadCollectionView(true)
    appDelegate!.setNavBarColor(color: colors!.navigationBarTint)
    performShading()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    scrollView!.contentSize = CGSize(width: contentView!.frame.width, height: contentView!.frame.height)
  }

  override func viewDidAppear(_ animated: Bool) {
    performShading()
    self.navigationController?.setNavigationBarHidden(false, animated: false)
    scrollView?.delegate = self
    reloadCollectionView()
    super.viewDidAppear(animated)
  }

  private func performShading() {
    DispatchQueue.main.async {
      self.view!.backgroundColor = self.colors!.backgroundColor
    }
    UINavigationBar.appearance().barTintColor = colors!.navigationBarTint
    for period in classPeriods! {
      period.setColors(themeColors: colors!)
    }
    for (index, period) in (classPeriods!).enumerated() {
      var classData: SchoolClass
      if delegate!.isMiddleSchool && index == 6 {
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

  override func viewWillDisappear(_ animated: Bool) {
    scrollView!.delegate = nil
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  //swiftlint:disable cyclomatic_complexity
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // tapped on a class label
    if segue.identifier!.hasPrefix("ClassDetail") {
      let index = Int(segue.identifier!.components(separatedBy: "_")[1])
      if let receivingController = segue.destination as? ClassPeriodViewController {
        receivingController.modalPresentationStyle = .popover
        receivingController.preferredContentSize = CGSize(width: 500, height: 260)
        receivingController.delegate = self
        receivingController.index = index!
      }
    } else if segue.identifier!.hasPrefix("Day") { //overriding a day's schedule
      let index = Int(segue.identifier!.components(separatedBy: "_")[1])
      if let receivingController = segue.destination as? ScheduleOverrideController {
        receivingController.modalPresentationStyle = .popover
        receivingController.delegate = self
        receivingController.index = index!
        let dateInformation = delegate!.datesForWeek[index!]
        receivingController.previousSchedule = dateInformation.Schedule
      }
    } else if segue.identifier! == "WebView"{ //opening a webview...does this exist?
      if let url = sender as? URL {
        if let receivingController = segue.destination as? WebViewController {
          receivingController.initialURL = url
        }
      }
    } else if segue.identifier! == "ShowDetail" || segue.identifier! == "ReplaceDetail" { //tapped on an individual class period cell
      if let receivingController = segue.destination as? TaskEditViewController {
        receivingController.taskDelegate = appDelegate!.dataManager!
        let index = collectionView!.indexPathsForSelectedItems![0]
        let selectedIndex = dayAndPeriodFromIndexPath(index.row)
        receivingController.setData(date: delegate!.datesForWeek[selectedIndex.day].Date, period: selectedIndex.period)
        receivingController.colors = colors
      }
    } else if segue.identifier! == "JumpToDate" { //selected a new date in the picker
      if let receivingController = segue.destination as? JumpToDateViewController {
        receivingController.dataManager = delegate!
      }
    } else if segue.identifier! == "LinksPage" { //tapped the links page button
      if let receivingController = segue.destination as? LinksPageViewController {
        receivingController.colors = colors
      }
    }
    super.prepare(for: segue, sender: sender)
  }
  //swiftlint:enable cyclomatic_complexity

  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    coordinator.animate(alongsideTransition: nil, completion: {(_: UIViewControllerTransitionCoordinatorContext!) -> Void in
      self.deviceOrientationisPortrait = size.width < size.height
      self.collectionView!.collectionViewLayout.invalidateLayout()
      self.scrollView!.contentSize = CGSize(width: size.width, height: self.collectionView!.frame.height)
      return
    })
  }

  func showDetail(_ task: DailyTask) {
    self.performSegue(withIdentifier: "ReplaceDetail", sender: self)
  }

  func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
    if gestureRecognizer.state != UIGestureRecognizer.State.ended {
      return
    }
    let p = gestureRecognizer.location(in: self.collectionView)
    let indexPath = self.collectionView?.indexPathForItem(at: p)

    if indexPath != nil {
        let view = self.collectionView?.cellForItem(at: indexPath!)
      let menuController = UIMenuController.shared
      let selectionRectangle = CGRect(x: p.x, y: p.y, width: 100, height: 100)
        menuController.showMenu(from: view!, rect: selectionRectangle)
    }
  }
}

//MARK - UICollectionViewDelegate
extension MainViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    detailIndex = dayAndPeriodFromIndexPath((indexPath as NSIndexPath).row)
  }

  func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
    return true
  }

  func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
    if action == #selector(UIResponderStandardEditActions.cut(_:)) {
      return true
    } else if action == #selector(UIResponderStandardEditActions.copy(_:)) {
      return true
    } else if action == #selector(UIResponderStandardEditActions.paste(_:)) {
      return delegate!.hasCopiedTasks()
    } else {
      return false
    }
  }

  func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    let dayAndPeriod = dayAndPeriodFromIndexPath((indexPath as NSIndexPath).row)
    if action == #selector(UIResponderStandardEditActions.copy(_:)) {
      delegate!.copyTasksFor(dayAndPeriod.day, period: dayAndPeriod.period)
    } else if action == #selector(UIResponderStandardEditActions.paste(_:)) {
      delegate!.pasteTasksTo(dayAndPeriod.day, period: dayAndPeriod.period)
    } else if action == #selector(UIResponderStandardEditActions.cut(_:)) {
      delegate!.copyTasksFor(dayAndPeriod.day, period: dayAndPeriod.period)
      delegate!.deleteAllTasksFrom(dayAndPeriod.day, period: dayAndPeriod.period)
    }
    return
  }
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
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
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if delegate!.shouldDisplayExtraRow {
      return 40
    } else {
      return 35
    }
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = self.collectionView!.dequeueReusableCell(withReuseIdentifier: "ClassPeriodTaskSummary", for: indexPath) as? DailyTaskSmallView else {
      return UICollectionViewCell()
    }
    cell.colors = self.colors
    var shadingType: CellShadingType = .noShading
    let selectedDayIndexes = dayAndPeriodFromIndexPath((indexPath as NSIndexPath).row)
    if delegate!.isMiddleSchool && (selectedDayIndexes.period == 7) {
      shadingType = .noShading
    } else if shadedRowIndexes[selectedDayIndexes.period]! && delegate!.shouldShadeStudyHall {
      shadingType = .studyHall
    } else if delegate!.missedClassesForDayByIndex(selectedDayIndexes.day).contains(selectedDayIndexes.period) {
      shadingType = .noClass
    }
    cell.shouldShadeCell(shadingType)
    let summary = taskSummaries![(indexPath as NSIndexPath).row]
    cell.setTopTaskLabel(summary.title, isTaskCompleted: summary.completion, decorationType: appDelegate!.userDefaults.decorationType)
    cell.setRemainingTasksLabel(tasksRemaining: summary.remainingTasks)
    return cell
  }

  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    guard let header = self.collectionView?.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "dateHeaderBlock", for: indexPath) as? DateHeaderView else {
      let defaultHeader = DateHeaderView()
      defaultHeader.SetDates(delegate!.datesForWeek)
      return defaultHeader
    }
    header.SetDates(delegate!.datesForWeek)
    return header
  }

  func reloadCollectionView(_ settingsDidChange: Bool=false) {
    taskSummaries = delegate!.summariesForWeek()
    if settingsDidChange { performShading() }
    DispatchQueue.main.async {
      self.collectionView!.reloadData()
    }
    
  }
}

//MARK - ClassPeriodDataSource compliance
extension MainViewController: ClassPeriodDataSource {
  func setClassData(_ data: SchoolClass, forIndex index: Int) {
    classPeriods![index].classData = data
    if data.isStudyHall {
      shouldShadeRow(true, forPeriod: index + 1) //period indexes start at 1
    } else {
      shouldShadeRow(false, forPeriod: index + 1)
    }
    classRepository!.persistData(data)
  }

  func getClassData(_ period: Int) -> SchoolClass {
    return classPeriods![period].classData
  }

  func openWebView(_ url: URL) {
    performSegue(withIdentifier: "WebView", sender: url)
  }

  func shouldShadeRow(_ value: Bool, forPeriod: Int) {
    let oldValue = shadedRowIndexes[forPeriod]!
    if value != oldValue {
      shadedRowIndexes[forPeriod] = value
      reloadCollectionView()
    }
  }
}

extension MainViewController: ScheduleOverrideDelegate {
  func updateScheduleForIndex(_ index: Int, withSchedule schedule: String) {
    delegate!.didSetDateByIndex(index, withData: schedule)
    reloadCollectionView()
  }
}

extension MainViewController: UIGestureRecognizerDelegate {
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
}

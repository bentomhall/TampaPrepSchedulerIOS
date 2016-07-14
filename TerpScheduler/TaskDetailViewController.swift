//
//  TaskDetailViewController.swift
//  TerpScheduler
//
//  Created by Ben Hall on 1/20/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import UIKit

@IBDesignable
class TaskDetailViewController: UIViewController {
  @IBOutlet weak var titleField: UITextField?
  @IBOutlet weak var detailsTextView: UITextView?
  @IBOutlet weak var prioritySelector: UISegmentedControl?
  @IBOutlet weak var isHaikuAssignment: UISwitch?
  @IBOutlet weak var isCompleted: UISwitch?
  @IBOutlet weak var shouldNotify: UISwitch?
  @IBOutlet weak var dateLabel: UILabel?
  
  @IBAction func clearData(sender: UIBarButtonItem) {
    shouldSave = false
    splitViewController!.preferredDisplayMode = .PrimaryHidden
    navigationController!.popToRootViewControllerAnimated(false)
    clear()
  }
  
  @IBAction func addItem(sender: UIBarButtonItem) {
    saveData()
    clear()
    taskIsPersisted = false
    shouldSave = true
    delegate!.addItemToTableView()
  }
  
  private var shouldSave: Bool = true
  private var taskIsPersisted: Bool = false
  
  var delegate: TaskDetailDelegate?
  var previousTaskData: DailyTask? {
    willSet(value) {
      if value == delegate!.defaultTask {
        return
      }
      if date == nil && value != nil{
        date = value!.date
        period = value!.period
      }
    }
  }
  
  var date: NSDate?
  var period: Int?
  
  func stringFromDate(date: NSDate)->String
  {
    let formatter = NSDateFormatter()
    formatter.dateFormat = "MM/dd/YYYY"
    return formatter.stringFromDate(date)
  }
  
  func clear(){
    titleField!.text = ""
    detailsTextView!.text = ""
    prioritySelector!.selectedSegmentIndex = 2
    isHaikuAssignment!.on = false
    isCompleted!.on = false
    shouldNotify!.on = false
    previousTaskData = delegate!.defaultTask
    taskIsPersisted = false
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.setHidesBackButton(true, animated: false)
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    self.dateLabel!.text = stringFromDate(date ?? NSDate()) + ": period \(period!)"
    self.delegate = appDelegate.dataManager
    delegate!.detailViewController = self
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    setSubviewContentsFromTaskData(previousTaskData)
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    if shouldSave {
      saveData()
    }
  }
  
  @IBAction func notificationStatusChanged(sender: UISwitch)
  {
    if previousTaskData == nil {
      return
    }
    if taskIsPersisted {
      if sender.on {
        delegate!.postNotification(forTask: previousTaskData!)
      } else {
        delegate!.cancelNotificationMatching(previousTaskData!)
      }
    }
  }
  
  func saveData() {
    if titleField!.text != "" {
      let shortTitle = titleField!.text
      let details = detailsTextView!.text
      var priority = Priorities(rawValue: prioritySelector!.selectedSegmentIndex)
      let isHaiku = isHaikuAssignment!.on
      let completion = isCompleted!.on
      let notification = shouldNotify!.on
      if completion {
        priority = Priorities.Completed
      }
      
      let newTaskData = DailyTask(date: date!, period: period!, shortTitle: shortTitle!, details: details, isHaiku: isHaiku, completion: completion, priority: priority!, notify: notification)
      if newTaskData != previousTaskData! {
        delegate!.updateTask(newTaskData, withPreviousTask: previousTaskData!)
        previousTaskData = newTaskData
      }
      taskIsPersisted = true
    }
  }
  
  func setSubviewContentsFromTaskData(data: DailyTask?){
    if data != nil {
      titleField!.text = data!.shortTitle
      detailsTextView!.text = data!.details
      prioritySelector!.selectedSegmentIndex = data!.priority.rawValue
      isHaikuAssignment!.setOn(data!.isHaikuAssignment, animated: false)
      isCompleted!.setOn(data!.isCompleted, animated: false)
      shouldNotify?.setOn(data!.shouldNotify, animated: false)
      taskIsPersisted = true
    }
  }
}

extension TaskDetailViewController: UITextFieldDelegate {
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
  
  func textFieldDidEndEditing(textField: UITextField) {
    delegate!.didUpdateTitle(textField.text!)
  }
}

extension TaskDetailViewController: UITextViewDelegate {
  func textViewDidEndEditing(textView: UITextView) {
    textView.resignFirstResponder()
  }
}

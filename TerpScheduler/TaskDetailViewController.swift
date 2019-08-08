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
  @IBOutlet var textLabels: [UILabel]?

  @IBAction func clearData(_ sender: UIBarButtonItem) {
    shouldSave = false
    splitViewController!.preferredDisplayMode = .primaryHidden
    navigationController!.popToRootViewController(animated: false)
    clear()
  }

  @IBAction func addItem(_ sender: UIBarButtonItem) {
    saveData()
    clear()
    taskIsPersisted = false
    shouldSave = true
    delegate!.addItemToTableView()
  }

  fileprivate var shouldSave: Bool = true
  fileprivate var taskIsPersisted: Bool = false

  weak var delegate: TaskDetailDelegate?
  weak var colors: UserColors?
  var previousTaskData: DailyTask? {
    willSet(value) {
      if value == delegate!.defaultTask {
        return
      }
      if date == nil && value != nil {
        date = value!.date as Date
        period = value!.period
      }
    }
  }

  var date: Date?
  var period: Int?

  func stringFromDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MM/dd/YYYY"
    return formatter.string(from: date)
  }

  func clear() {
    titleField!.text = ""
    detailsTextView!.text = ""
    prioritySelector!.selectedSegmentIndex = 2
    isHaikuAssignment!.isOn = false
    isCompleted!.isOn = false
    shouldNotify!.isOn = false
    previousTaskData = delegate!.defaultTask
    taskIsPersisted = false
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.setHidesBackButton(true, animated: false)
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
      // can't happen
      return
    }
    self.dateLabel!.text = stringFromDate(date ?? Date()) + ": period \(period!)"
    self.delegate = appDelegate.dataManager
    delegate!.detailViewController = self
    colors = appDelegate.userColors!
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    setColorScheme()
    setSubviewContentsFromTaskData(previousTaskData)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    if shouldSave {
      saveData()
    }
  }
  
  func setColorScheme() {
    self.view.backgroundColor = colors!.backgroundColor
    for label in textLabels! {
      label.textColor = colors!.textColor
    }
    prioritySelector!.tintColor = colors!.textColor
  }

  @IBAction func notificationStatusChanged(_ sender: UISwitch) {
    if previousTaskData == nil {
      return
    }
    if taskIsPersisted {
      if sender.isOn {
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
      let isHaiku = isHaikuAssignment!.isOn
      let completion = isCompleted!.isOn
      let notification = shouldNotify!.isOn
      if completion {
        priority = Priorities.completed
      }

      let newTaskData = DailyTask(date: date!, period: period!, shortTitle: shortTitle!, details: details!, isHaiku: isHaiku, completion: completion, priority: priority!, notify: notification)
      if newTaskData != previousTaskData! {
        delegate!.updateTask(newTaskData, withPreviousTask: previousTaskData!)
        previousTaskData = newTaskData
      }
      taskIsPersisted = true
    }
  }

  func setSubviewContentsFromTaskData(_ data: DailyTask?) {
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
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }

  func textFieldDidEndEditing(_ textField: UITextField) {
    if textField == titleField! {
        delegate!.didUpdateTitle(textField.text!)
    }
  }
}

extension TaskDetailViewController: UITextViewDelegate {
  func textViewDidEndEditing(_ textView: UITextView) {
    textView.resignFirstResponder()
  }
}

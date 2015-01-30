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
  
  var delegate: TaskDetailDelegate?
  var previousTaskData: DailyTask?
  var date: NSDate?
  var period: Int?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    self.delegate = appDelegate.dataManager
    delegate!.detailViewController = self
    
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    setSubviewContentsFromTaskData(previousTaskData)
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    if titleField!.text != "" {
      let shortTitle = titleField!.text
      let details = detailsTextView!.text
      let priority = Priorities(rawValue: prioritySelector!.selectedSegmentIndex)
      let isHaiku = isHaikuAssignment!.on
      let completion = isCompleted!.on
      let newTaskData = DailyTask(date: date!, period: period!, shortTitle: shortTitle, details: details, isHaiku: isHaiku, completion: completion, priority: priority!)
      if newTaskData != previousTaskData! {
        delegate!.updateTask(newTaskData, withPreviousTask: previousTaskData!)
      }
    }
  }
  
  func setSubviewContentsFromTaskData(data: DailyTask?){
    if data != nil {
      //default case
      titleField!.text = data!.shortTitle
      detailsTextView!.text = data!.details
      prioritySelector!.selectedSegmentIndex = data!.priority.rawValue
      isHaikuAssignment!.setOn(data!.isHaikuAssignment, animated: false)
      isCompleted!.setOn(data!.isCompleted, animated: false)
    }
  }
  
  
  /*
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  // Get the new view controller using segue.destinationViewController.
  // Pass the selected object to the new view controller.
  }
  */
  
}

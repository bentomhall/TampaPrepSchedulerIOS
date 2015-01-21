//
//  TaskDetailViewController.swift
//  TerpScheduler
//
//  Created by Ben Hall on 1/20/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import UIKit

protocol TaskDetailDelegate{
  func updateTaskData(data: DailyTaskData)
  var nextID: Int { get }
}

@IBDesignable
class TaskDetailViewController: UIViewController {
  @IBOutlet weak var titleField: UITextField?
  @IBOutlet weak var detailsTextView: UITextView?
  @IBOutlet weak var prioritySelector: UISegmentedControl?
  @IBOutlet weak var isHaikuAssignment: UISwitch?
  @IBOutlet weak var isCompleted: UISwitch?
  
  var delegate: TaskDetailDelegate?
  var previousTaskData: DailyTaskData?
  
    override func viewDidLoad() {
        super.viewDidLoad()

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
    let shortTitle = titleField!.text
    let details = detailsTextView!.text
    let priority = prioritySelector!.selectedSegmentIndex
    let isHaiku = isHaikuAssignment!.on
    let completion = isCompleted!.on
    let newTaskData = DailyTaskData(id: delegate!.nextID, due: previousTaskData!.due, shortTitle: shortTitle, details: details, isHaikuAssignment: isHaiku, isCompleted: completion, priority: Priorities(rawValue: priority)!)
    delegate!.updateTaskData(newTaskData)
  }
  
  func setSubviewContentsFromTaskData(data: DailyTaskData?){
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

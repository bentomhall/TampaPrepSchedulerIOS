//
//  TaskTableViewController.swift
//  TerpScheduler
//
//  Created by Ben Hall on 1/20/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import UIKit

protocol TaskDataDelegate {
  func addTask(taskData: DailyTaskData)
  func removeTask(taskData: DailyTaskData)
  var nextID:Int { get }
  func reload()
  func getSelected()->DailyTaskData?
}

class TaskTableViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate {
  var date = NSDate()
  var period = 1
  var repository: TaskCollectionRepository?
  var tasks: [DailyTaskData] = []
  var nextID: Int {
    get { return tasks.count }
  }
  func loadTasks(date: NSDate, andPeriod period:Int){
    if repository != nil {
      tasks = repository!.tasksForDateAndPeriod(date, period: period)
    }
    self.date = date
    self.period = period
  }
  var selectedTask: DailyTaskData?
  
  
  var delegate: TaskDataDelegate?
  
  override func viewDidLoad() {
    self.navigationItem.rightBarButtonItem = self.editButtonItem()
  }
  
  override func viewDidAppear(animated: Bool) {
    tableView.reloadData()
  }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
      return tasks.count + 1
    }
  
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCellWithIdentifier("TaskListView", forIndexPath: indexPath) as TaskTableViewCell
      if indexPath.row == tasks.count {
        cell.textLabel!.text = "Press to add a task"
      } else {
        cell.textLabel!.text = tasks[indexPath.row].shortTitle
      }
      return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
          tasks.removeAtIndex(indexPath.row)
          tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if tasks.count == 0 {
      selectedTask = DailyTaskData(id: 0, due: date, shortTitle: "", details: "", isHaikuAssignment: false, isCompleted: false, priority: Priorities.Medium)
    } else {
      selectedTask = tasks[indexPath.row]
    }
  }
}

extension TaskTableViewController: TaskDataDelegate {
  func addTask(taskData: DailyTaskData) {
    tasks.append(taskData)
    tableView.reloadData()
    repository!.modelFromData(taskData, forPeriod: period)
  }
  
  func removeTask(taskData: DailyTaskData) {
    let index = find(tasks, taskData)
    tasks.removeAtIndex(index!)
  }
  
  func reload(){
    tableView.reloadData()
  }
  
  func getSelected() -> DailyTaskData? {
    if selectedTask == nil {
      selectedTask = DailyTaskData(id: 0, due: date, shortTitle: "", details: "", isHaikuAssignment: false, isCompleted: false, priority: Priorities.Medium)
    }
    return selectedTask
  }
}

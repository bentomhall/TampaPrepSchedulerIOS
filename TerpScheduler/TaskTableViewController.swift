//
//  TaskTableViewController.swift
//  TerpScheduler
//
//  Created by Ben Hall on 1/20/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import UIKit

class TaskTableViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate {
  @IBAction func hideTableView(recognizer: UISwipeGestureRecognizer){
    delegate!.willDisappear()
    self.splitViewController!.preferredDisplayMode = UISplitViewControllerDisplayMode.PrimaryHidden
  }
  
  var date = NSDate()
  var period = 1
  var tasks: [DailyTask] = []
  var delegate: TaskTableDelegate?
  
  var selectedTask: DailyTask?
  
  func reload(){
    tableView.reloadData()
  }
  
  override func viewDidLoad() {
    self.navigationItem.rightBarButtonItem = self.editButtonItem()
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    self.delegate = appDelegate.dataManager
    self.delegate!.tableViewController = self
  }
  
  override func viewDidAppear(animated: Bool) {
    tableView.reloadData()
  }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
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
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier! == "ReturnToMain"{
      self.splitViewController!.preferredDisplayMode = UISplitViewControllerDisplayMode.PrimaryHidden
    
    } else {
      let receiver = segue.destinationViewController as TaskDetailViewController
      let index = tableView.indexPathForSelectedRow()?.row
      if tasks.count == 0 || index == tasks.count {
        selectedTask = delegate!.defaultTask
      } else {
        if index != nil {
          selectedTask = tasks[index!]
        }
      }
      delegate?.willDisplayDetailForTask(selectedTask!, forViewController: receiver)
  
    }
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
          let item = tasks[indexPath.row]
          tasks.removeAtIndex(indexPath.row)
          delegate!.didDeleteTask(item)
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
    tableView.reloadData()
  }
}

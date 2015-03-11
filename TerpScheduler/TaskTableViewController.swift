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
  @IBAction func doneButton(sender: UIBarButtonItem){
    delegate!.willDisappear()
    self.splitViewController!.preferredDisplayMode = .PrimaryHidden
  }
  
  var date = NSDate()
  var period = 1
  var tasks: [DailyTask] = []
  var delegate: TaskTableDelegate?
  var dirtyCellTitles = [Int: String]()
  
  var selectedTask: DailyTask?
  var selectedRow = NSIndexPath(forRow: 0, inSection: 0)
  
  func reload(){
    tableView.reloadData()
  }
  
  func clearDirtyRows(){
    dirtyCellTitles = [Int: String]()
  }
  
  func addAndSelectItem(task: DailyTask?, forIndex indx: Int){
    var indexPath: NSIndexPath
    var row: Int
    if task != nil {
      self.tasks.append(task!)
      self.reload()
      row = tasks.count - 1
    } else {
      row = indx
    }
    indexPath = NSIndexPath(forRow: row, inSection: 0)
    selectedRow = indexPath
    self.tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .None)
  }
  
  override func viewDidLoad() {
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
    dirtyCellTitles = [Int: String]()
  }
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    // Return the number of sections.
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // Return the number of rows in the section.
    return tasks.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("TaskListView", forIndexPath: indexPath) as TaskTableViewCell
    let task = tasks[indexPath.row]
    let title = task.shortTitle
    if !contains(dirtyCellTitles.keys, indexPath.row) {
      cell.setTitleText(title, taskIsComplete: task.isCompleted)
    } else {
      cell.setTitleText(dirtyCellTitles[indexPath.row]!, taskIsComplete: false)
    }
    return cell
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    selectedTask = tasks[indexPath.row]
    delegate!.willDisplayDetailForTask(selectedTask!)
    selectedRow = indexPath
  }
  
  // Override to support conditional editing of the table view.
  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return NO if you do not want the specified item to be editable.
    return true
  }
  
  // Override to support editing the table view.
  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
      // Delete the row from the data source
      let item = tasks[indexPath.row]
      tasks.removeAtIndex(indexPath.row)
      delegate!.didDeleteTask(item)
      tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    }
  }
  
  func updateTitleOfSelectedCell(title: String){
    dirtyCellTitles[selectedRow.row] = title
    tableView.reloadData()
  }
  
  func replaceItem(index: Int, withTask: DailyTask){
    if index >= 0 {
      tasks[index] = withTask
    } else {
      tasks[selectedRow.row] = withTask
    }
    tableView.reloadData()
  }
  
  
}

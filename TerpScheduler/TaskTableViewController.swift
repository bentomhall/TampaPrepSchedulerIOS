//
//  TaskTableViewController.swift
//  TerpScheduler
//
//  Created by Ben Hall on 1/20/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import UIKit

class TaskTableViewController: UITableViewController {
  @IBAction func hideTableView(_ recognizer: UISwipeGestureRecognizer) {
    delegate!.willDisappear()
    self.splitViewController!.preferredDisplayMode = UISplitViewControllerDisplayMode.primaryHidden
  }

  @IBAction func doneButton(_ sender: UIBarButtonItem) {
    delegate!.willDisappear()
    self.splitViewController!.preferredDisplayMode = .primaryHidden
  }

  @IBAction func addTaskButton(_ sender: UIBarButtonItem) {
    delegate!.addItemToTableView()
  }

  var date = Date()
  var period = 1
  var tasks: [DailyTask] = []
  weak var delegate: TaskTableDelegate?
  var dirtyCellTitles = [Int: String]()
  var selectedTask: DailyTask?
  var selectedRow = IndexPath(row: 0, section: 0)
  weak var colors: UserColors?

  func reload() {
    tableView.reloadData()
  }

  func clearDirtyRows() {
    dirtyCellTitles = [Int: String]()
  }

  func addAndSelectItem(_ task: DailyTask?, forIndex indx: Int) {
    var indexPath: IndexPath
    var row: Int
    if task != nil {
      self.tasks.append(task!)
      self.reload()
      row = tasks.count - 1
    } else {
      row = indx
    }
    indexPath = IndexPath(row: row, section: 0)
    selectedRow = indexPath
    self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
  }
  
  @objc func userColorsDidChange() {
    DispatchQueue.main.async {
        self.tableView.backgroundView?.backgroundColor = self.colors!.backgroundColor
        self.tableView.tableFooterView!.backgroundColor = self.colors!.backgroundColor
    }
    
  }

  override func viewDidLoad() {
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    self.delegate = appDelegate!.dataManager
    self.delegate!.tableViewController = self
    colors = appDelegate!.userColors
    tableView.tableFooterView = UIView()
    tableView.backgroundView = UIView()
    userColorsDidChange()
    NotificationCenter.default.addObserver(self, selector: #selector(self.userColorsDidChange), name: UserDefaults.didChangeNotification, object: nil)
  }

//  override func viewDidAppear(_ animated: Bool) {
//    tableView.backgroundView?.backgroundColor = colors!.backgroundColor
//    tableView.tableFooterView!.backgroundColor = colors!.backgroundColor
//    tableView.reloadData()
//  }
//  
//  override func viewWillAppear(_ animated: Bool) {
//    tableView.backgroundView?.backgroundColor = colors!.backgroundColor
//    tableView.tableFooterView!.backgroundColor = colors!.backgroundColor
//    tableView.reloadData()
//  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    dirtyCellTitles = [Int: String]()
    NotificationCenter.default.removeObserver(self, name: UserDefaults.didChangeNotification, object: nil)
  }

  // MARK: - Table view data source
  override func numberOfSections(in tableView: UITableView) -> Int {
    // Return the number of sections.
    return 1
  }
  
  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    cell.backgroundColor = colors!.backgroundColor
    cell.tintColor = colors?.primaryThemeColor
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // Return the number of rows in the section.
    return tasks.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    let task = tasks[(indexPath as NSIndexPath).row]
    let title = task.shortTitle
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "TaskListView", for: indexPath) as? TaskTableViewCell else {
      let defaultCell = TaskTableViewCell()
      defaultCell.setTitleText(title, taskIsComplete: task.isCompleted, colors: colors!)
      return defaultCell
    }
    if !dirtyCellTitles.keys.contains((indexPath as NSIndexPath).row) {
      cell.setTitleText(title, taskIsComplete: task.isCompleted, colors: colors!)
    } else {
      cell.setTitleText(dirtyCellTitles[(indexPath as NSIndexPath).row]!, taskIsComplete: false, colors: colors!)
    }
    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    selectedTask = tasks[(indexPath as NSIndexPath).row]
    selectedRow = indexPath
    delegate!.willDisplayDetailForTask(selectedTask!)
  }

  // Override to support conditional editing of the table view.
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    // Return NO if you do not want the specified item to be editable.
    return true
  }

  // Override to support editing the table view.
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      // Delete the row from the data source
      let item = tasks[(indexPath as NSIndexPath).row]
      tasks.remove(at: (indexPath as NSIndexPath).row)
      delegate!.didDeleteTask(item)
      tableView.deleteRows(at: [indexPath], with: .fade)
    }
  }

  func updateTitleOfSelectedCell(_ title: String) {
    dirtyCellTitles[(selectedRow as NSIndexPath).row] = title
    tableView.reloadData()
  }

  func replaceItem(_ index: Int, withTask: DailyTask) {
    if index >= 0 {
      tasks[index] = withTask
    } else if tasks.count > 0 {
      tasks[(selectedRow as NSIndexPath).row] = withTask
    } else {
      tasks.append(withTask)
    }
    tableView.reloadData()
  }
}

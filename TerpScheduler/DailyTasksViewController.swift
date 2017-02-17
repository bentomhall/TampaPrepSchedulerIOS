//
//  DailyTasksViewController.swift
//  TerpScheduler
//
//  Created by Ben Hall on 1/7/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class DailyTasksTableViewController: UITableViewController, UITableViewDelegate,
    UITableViewDataSource {

    var savedTasks: [DailyTaskData] = []
    var tasksForPeriodRepository: DailyTasksForPeriod?

    override func viewWillAppear(animated: Bool) {
        //
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _tasks.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = self.tableView.dequeueReusableCellWithIdentifier("TaskDetail") as UITableViewCell
        let task = _tasks[indexPath.row]
        cell.textLabel!.text = task.shortTitle
        cell.detailTextLabel!.text = task.details
        if task.isCompleted {
            cell.backgroundColor = UIColor.lightGrayColor()
        } else if task.priority == Priorities.Highest || task.priority == Priorities.High {
            cell.backgroundColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.5)
        } else if task.priority == Priorities.Low || task.priority == Priorities.Lowest {
            cell.backgroundColor = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 0.5)
        }
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

    }

    func ReloadModel(dateString: String) {
        return
    }
}

//
//  ScheduleOverrideController.swift
//  TerpScheduler
//
//  Created by Ben Hall on 1/18/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import UIKit

protocol ScheduleOverrideDelegate: class {
  func updateScheduleForIndex(_ index: Int, withSchedule schedule: String)
}

@IBDesignable
class ScheduleOverrideController: UITableViewController {
  weak var delegate: ScheduleOverrideDelegate?
  var index: Int = 0
  var schedule = ""
  var previousSchedule = ""
  var date = ""
  var scheduleTypes: ScheduleTypeData?

  override func viewDidLoad() {
    super.viewDidLoad()
    if let appDelegate = UIApplication.shared.delegate! as? AppDelegate {
      scheduleTypes = appDelegate.scheduleTypes!
    }
    // Do any additional setup after loading the view.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let letter = scheduleTypes!.scheduleForIndex((indexPath as NSIndexPath).row)
    let classes = scheduleTypes!.scheduleForLetter(letter)
    let cell = tableView.dequeueReusableCell(withIdentifier: "scheduleTypeCell")
    if classes == "" {
      cell!.textLabel!.text = "Schedule \(letter): School Closed"
    } else {
      cell!.textLabel!.text = "Schedule \(letter): Periods \(classes!) meet"
    }
    if previousSchedule == letter {
      cell!.accessoryType = UITableViewCellAccessoryType.checkmark
    } else {

    }
    return cell!
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return scheduleTypes!.count
  }

  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return false
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let letter = scheduleTypes!.scheduleForIndex((indexPath as NSIndexPath).row)
    let cell = self.tableView(tableView, cellForRowAt: indexPath)
    cell.accessoryType = .checkmark
    delegate!.updateScheduleForIndex(index, withSchedule: letter)
    self.dismiss(animated: false, completion: nil)
  }
}

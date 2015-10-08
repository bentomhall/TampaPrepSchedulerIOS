//
//  ScheduleOverrideController.swift
//  TerpScheduler
//
//  Created by Ben Hall on 1/18/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import UIKit

struct ScheduleTypes {
  let schedules: [String: String] = [
    "A": "1, 2, 3, 4, 5, 7",
    "B": "1, 2, 3, 4, 6",
    "C": "1, 2, 3, 5, 6, 7",
    "D": "1, 3, 4, 5, 6, 7",
    "E": "2, 4, 5, 6, 7",
    "Y": "1, 2, 3, 4, 5, 6, 7",
    "A*": "1, 2, 3",
    "A**": "4, 5, 7",
    "X": "",
    "Y*": "1, 2, 3, 4",
    "Y**": "5, 6, 7"
  ]
  
  var count: Int {
    get { return schedules.count }
  }
  
  var types: [String]{
    get {
      var letters : [String] = []
      for key in Array(schedules.keys).sort(<){
        letters.append(key)
      }
      return letters
    }
  }
  
  func indexForLetter(letter: String)->Int?{
    return types.indexOf(letter)
  }
  
  func scheduleForLetter(letter: String)->String?{
    return schedules[letter]
  }
  
  func scheduleForIndex(index: Int)->String{
    let key = types[index]
    return key
  }
}

protocol ScheduleOverrideDelegate{
  func updateScheduleForIndex(index: Int, withSchedule schedule: String)
}

@IBDesignable
class ScheduleOverrideController: UITableViewController {
  var delegate: ScheduleOverrideDelegate?
  var index: Int = 0
  var schedule = ""
  var previousSchedule = ""
  var date = ""
  let scheduleTypes = ScheduleTypes()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let letter = scheduleTypes.scheduleForIndex(indexPath.row)
    let classes = scheduleTypes.scheduleForLetter(letter)
    let cell = tableView.dequeueReusableCellWithIdentifier("scheduleTypeCell")
    if classes == "" {
      cell!.textLabel!.text = "Schedule \(letter): School Closed"
    } else {
      cell!.textLabel!.text = "Schedule \(letter): Periods \(classes!) meet"
    }
    if previousSchedule == letter {
      cell!.accessoryType = UITableViewCellAccessoryType.Checkmark
    } else {
      
    }
    return cell!
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return scheduleTypes.count
  }
  
  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return false
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let letter = scheduleTypes.scheduleForIndex(indexPath.row)
    let cell = self.tableView(tableView, cellForRowAtIndexPath: indexPath)
    cell.accessoryType = .Checkmark
    delegate!.updateScheduleForIndex(index, withSchedule: letter)
    self.dismissViewControllerAnimated(false, completion: nil)
  }
}


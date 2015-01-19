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
    "X": ""
  ]
  
  var count: Int {
    get { return schedules.count }
  }
  
  var types: [String]{
    get {
      var letters : [String] = []
      for key in schedules.keys{
        letters.append(key)
      }
      return letters
    }
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
class ScheduleOverrideController: UIViewController {
  @IBOutlet weak var schedulePicker: UIPickerView?
  @IBOutlet weak var dateLabel: UILabel?
  var delegate: ScheduleOverrideDelegate?
  var index: Int = 0
  var schedule = ""
  var previousSchedule = ""
  var date = ""
  let scheduleTypes = ScheduleTypes()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    dateLabel!.text = "Schedule for \(date)"
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewWillDisappear(animated: Bool) {
    if schedule == ""{
      schedule = previousSchedule
    }
    delegate!.updateScheduleForIndex(index, withSchedule: schedule)
    super.viewWillDisappear(animated)
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

extension ScheduleOverrideController: UIPickerViewDataSource {
  func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return scheduleTypes.count
  }
  
  
  func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
    return 1
  }
}

extension ScheduleOverrideController: UIPickerViewDelegate{
  func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
    let key = scheduleTypes.scheduleForIndex(row)
    let value = scheduleTypes.scheduleForLetter(key)!
    if value == ""{
      return "Schedule \(key): School Closed"
    }
    return "Schedule \(key): Periods \(value) meet"
  }
  
  func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    schedule = scheduleTypes.scheduleForIndex(row)
  }
}

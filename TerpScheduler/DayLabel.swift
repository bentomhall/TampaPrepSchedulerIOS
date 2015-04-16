//
//  DayLabel.swift
//  TerpScheduler
//
//  Created by Ben Hall on 12/21/14.
//  Copyright (c) 2014 Tampa Preparatory School. All rights reserved.
//

import UIKit


@IBDesignable
class DayLabel: UIView, UITextFieldDelegate {
  
  @IBOutlet weak var dateLabel: UILabel?
  @IBOutlet weak var scheduleLabel: UILabel?
  @IBOutlet weak var selectedView: UIView?
  
  let dateFormat = "E MM/d"
  var dateFormatter = NSDateFormatter()
  
  func SetContents(date day: NSDate, scheduleType: String, dateIsToday: Bool, dayInformation: String? = nil){
    self.dateFormatter.dateFormat = dateFormat
    dateLabel!.text = dateFormatter.stringFromDate(day)
    scheduleLabel!.text = scheduleType
    selectedView?.layer.cornerRadius = selectedView!.frame.width/2.0
    if dateIsToday{
      selectedView?.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.25)
    }
    else {
      selectedView?.backgroundColor = UIColor.clearColor()
    }
    return
  }
}


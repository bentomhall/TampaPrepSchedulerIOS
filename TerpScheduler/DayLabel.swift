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
  var dateFormatter = DateFormatter()

  func setContents(date day: Date, scheduleType: String, dateIsToday: Bool, dayInformation: String? = nil) {
    var colors: UserColors?
    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
       colors = appDelegate.userColors!
    }
    self.dateFormatter.dateFormat = dateFormat
    dateLabel!.text = dateFormatter.string(from: day)
    scheduleLabel!.text = scheduleType
    dateLabel!.textColor = colors!.textColor
    scheduleLabel!.textColor = colors!.textColor
    selectedView?.layer.cornerRadius = selectedView!.frame.width/2.0
    if dateIsToday {
      selectedView?.backgroundColor = colors!.todayLabelColor
    } else {
      selectedView?.backgroundColor = UIColor.clear
    }
    return
  }
}

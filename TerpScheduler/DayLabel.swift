//
//  DayLabel.swift
//  TerpScheduler
//
//  Created by Ben Hall on 12/21/14.
//  Copyright (c) 2014 Tampa Preparatory School. All rights reserved.
//

import UIKit


@IBDesignable
class DayLabel: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    @IBOutlet weak var DateLabel: UILabel?
    @IBOutlet weak var ScheduleLabel: UILabel?
  @IBOutlet weak var selectedView: UIView?
    
  func SetContents(date day: NSDate, scheduleType: String, dateIsToday: Bool){
    var formatter = NSDateFormatter()
    formatter.dateFormat = "E MM/d"
    DateLabel!.text = formatter.stringFromDate(day)
    ScheduleLabel!.text = scheduleType
    
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

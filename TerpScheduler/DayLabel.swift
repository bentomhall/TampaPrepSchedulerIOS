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

    @IBOutlet var DateLabel: UILabel?
    @IBOutlet var ScheduleLabel: UILabel?
    
    func SetContents(date day: NSDate, scheduleType: String){
        var formatter = NSDateFormatter()
        formatter.dateFormat = "E MM/d"
        DateLabel!.text = formatter.stringFromDate(day)
        ScheduleLabel!.text = scheduleType
        return
    }
}

//
//  DayLabelViewController.swift
//  TerpScheduler
//
//  Created by Ben Hall on 12/20/14.
//  Copyright (c) 2014 Tampa Preparatory School. All rights reserved.
//

import Foundation
import UIKit

class DayLabelViewController: UIViewController {
    @IBOutlet var DayDateLabel: UILabel!
    @IBOutlet var ScheduleTypeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func SetDate(properDate:NSDate){
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEEEE MMM d"
        DayDateLabel.text = formatter.stringFromDate(properDate)
    }
    
    func SetScheduleType(scheduleLetter: NSString){
        ScheduleTypeLabel.text = scheduleLetter
    }
}

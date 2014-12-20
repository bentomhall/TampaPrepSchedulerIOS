//
//  DayListViewController.swift
//  TerpScheduler
//
//  Created by Ben Hall on 12/19/14.
//  Copyright (c) 2014 Tampa Preparatory School. All rights reserved.
//

import Foundation
import UIKit

class TaskViewController: UIViewController {
    @IBOutlet var HighestPriorityTaskTitleLabel: UILabel!
    @IBOutlet var OtherTasksCountLabel: UILabel!
    @IBAction func TapGestureRecognizer(recognizer: UITapGestureRecognizer){
        self.SetHighestPriorityTaskTitle("Dummy!")
        self.SetOtherTasksCount(12)
    }
    
    
    func SetHighestPriorityTaskTitle(title: NSString){
        HighestPriorityTaskTitleLabel.text = title
        HighestPriorityTaskTitleLabel.textColor = UIColor.redColor()
    }
    
    func SetOtherTasksCount(count: Int){
        OtherTasksCountLabel.text = "+\(count) other tasks"
        
    
    }
}

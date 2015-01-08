//
//  DailyTaskSmallView.swift
//  TerpScheduler
//
//  Created by Ben Hall on 1/7/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import UIKit

@IBDesignable
class DailyTaskSmallView: UIView {

    @IBOutlet var TopTaskLabel : UILabel?
    @IBOutlet var RemainingTasksLabel : UILabel?
    
    func setTopTaskLabel(taskTitle: String){
        if taskTitle != "" {
            TopTaskLabel!.text! = taskTitle
        }
        else {
            TopTaskLabel!.text! = "No Tasks!"
        }
    }
    
    func setRemainingTasksLabel(tasksRemaining: Int){
        if tasksRemaining > 0 {
            let text = "+ \(tasksRemaining) others"
            RemainingTasksLabel!.text! = text
            if tasksRemaining > 2 {
                RemainingTasksLabel!.textColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
            }
            else {
                RemainingTasksLabel!.textColor = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
            }
        }
        else {
            RemainingTasksLabel?.hidden = true
        }

    }
    
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        
    }
    */

}

//
//  TaskTableViewCell.swift
//  TerpScheduler
//
//  Created by Ben Hall on 1/7/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import UIKit

@IBDesignable
class TaskTableViewCell: UITableViewCell {
    @IBOutlet weak var TopPriorityTaskLabel : UILabel?
    @IBOutlet weak var RemainingTasksLabel : UILabel?
    
    func setTopTaskLabel(taskTitle: String){
        if taskTitle != "" {
            TopPriorityTaskLabel!.text! = taskTitle
        }
        else {
            TopPriorityTaskLabel!.text! = "No Tasks!"
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

}

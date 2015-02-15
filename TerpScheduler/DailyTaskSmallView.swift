//
//  DailyTaskSmallView.swift
//  TerpScheduler
//
//  Created by Ben Hall on 1/7/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import UIKit

@IBDesignable
class DailyTaskSmallView: UICollectionViewCell {
  
  @IBOutlet var TopTaskLabel : UILabel?
  @IBOutlet var RemainingTasksLabel : UILabel?
  
  override func prepareForReuse() {
    TopTaskLabel!.text = ""
    RemainingTasksLabel!.text = ""
    RemainingTasksLabel!.hidden = false
  }
  
  func setTopTaskLabel(taskTitle: String, isTaskCompleted completion: Bool){
    TopTaskLabel!.text = taskTitle
    if completion {
      TopTaskLabel!.enabled = false
    }
  }
  
  func setRemainingTasksLabel(tasksRemaining: Int){
    if tasksRemaining > 0 {
      RemainingTasksLabel?.hidden = false
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
  
  
}

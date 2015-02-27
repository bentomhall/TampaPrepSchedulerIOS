//
//  DailyTaskSmallView.swift
//  TerpScheduler
//
//  Created by Ben Hall on 1/7/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import UIKit

enum CellShadingType {
  case noClass
  case studyHall
  case noShading
}

@IBDesignable
class DailyTaskSmallView: UICollectionViewCell {
  
  @IBOutlet weak var TopTaskLabel : UILabel?
  @IBOutlet weak var RemainingTasksLabel : UILabel?
  
  override func prepareForReuse() {
    TopTaskLabel!.text = ""
    RemainingTasksLabel!.text = ""
    RemainingTasksLabel!.hidden = false
  }
  
  func setTopTaskLabel(taskTitle: String, isTaskCompleted completion: Bool){
    if completion {
      TopTaskLabel!.attributedText = NSAttributedString(string: taskTitle, attributes: [NSStrikethroughStyleAttributeName: 2])
      TopTaskLabel!.enabled = false
    } else {
      TopTaskLabel!.attributedText = NSAttributedString(string: taskTitle)
      TopTaskLabel!.enabled = true
    }
  }
  
  func setRemainingTasksLabel(tasksRemaining: Int){
    if tasksRemaining > 0 {
      RemainingTasksLabel?.hidden = false
      let text = "+ \(tasksRemaining) others"
      RemainingTasksLabel!.text! = text
      if tasksRemaining > 1 {
        RemainingTasksLabel!.textColor = UIColor.redColor()
      }
      else if tasksRemaining == 1{
        RemainingTasksLabel!.text = "+ 1 other"
        RemainingTasksLabel!.textColor = UIColor.blueColor()
      }
    } else {
      RemainingTasksLabel?.hidden = true
    }
    
  }
  
  func shouldShadeCell(shadingType: CellShadingType){
    switch(shadingType){
    case .noClass:
      self.backgroundColor = UIColor(white: 0, alpha: 0.1)
      break
    case .studyHall:
      self.backgroundColor = UIColor(white: 0, alpha: 0.05)
      break
    case .noShading:
      self.backgroundColor = UIColor.whiteColor()
    }
  }
  
  
}

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
  
  @IBOutlet weak var topTaskLabel : UILabel?
  @IBOutlet weak var remainingTasksLabel : UILabel?
  
  override func prepareForReuse() {
    topTaskLabel!.text = ""
    remainingTasksLabel!.text = ""
    remainingTasksLabel!.hidden = false
  }
  
  func setTopTaskLabel(taskTitle: String, isTaskCompleted completion: Bool){
    if completion {
      topTaskLabel!.attributedText = NSAttributedString(string: taskTitle, attributes: [NSStrikethroughStyleAttributeName: 2])
      topTaskLabel!.enabled = false
    } else {
      topTaskLabel!.attributedText = NSAttributedString(string: taskTitle)
      topTaskLabel!.enabled = true
    }
  }
  
  func setRemainingTasksLabel(tasksRemaining remaining: Int){
    if remaining > 0 {
      remainingTasksLabel?.hidden = false
      let text = "+ \(remaining) others"
      remainingTasksLabel!.text! = text
      if remaining > 1 {
        remainingTasksLabel!.textColor = UIColor.redColor()
      }
      else if remaining == 1{
        remainingTasksLabel!.text = "+ 1 other"
        remainingTasksLabel!.textColor = UIColor.blueColor()
      }
    } else {
      remainingTasksLabel?.hidden = true
    }
    
  }
  
  func shouldShadeCell(shadingType: CellShadingType){
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let colors = appDelegate.userColors!
    switch(shadingType){
    case .noClass:
      self.backgroundColor = colors.NoClassColor
      break
    case .studyHall:
      self.backgroundColor = colors.StudyHallColor
      break
    case .noShading:
      self.backgroundColor = UIColor.whiteColor()
    }
  }
}

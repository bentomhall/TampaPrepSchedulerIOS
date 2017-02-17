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

  @IBOutlet weak var topTaskLabel: UILabel?
  @IBOutlet weak var remainingTasksLabel: UILabel?

  override func prepareForReuse() {
    topTaskLabel!.text = ""
    remainingTasksLabel!.text = ""
    remainingTasksLabel!.isHidden = false
  }

  func setTopTaskLabel(_ taskTitle: String, isTaskCompleted completion: Bool) {
    if completion {
      topTaskLabel!.attributedText = NSAttributedString(string: taskTitle, attributes: [NSStrikethroughStyleAttributeName: 2])
      topTaskLabel!.isEnabled = false
    } else {
      topTaskLabel!.attributedText = NSAttributedString(string: taskTitle)
      topTaskLabel!.isEnabled = true
    }
  }

  func setRemainingTasksLabel(tasksRemaining remaining: Int) {
    if remaining > 0 {
      remainingTasksLabel?.isHidden = false
      let text = "+ \(remaining) others"
      remainingTasksLabel!.text! = text
      if remaining > 1 {
        remainingTasksLabel!.textColor = UIColor.red
      } else if remaining == 1 {
        remainingTasksLabel!.text = "+ 1 other"
        remainingTasksLabel!.textColor = UIColor.blue
      }
    } else {
      remainingTasksLabel?.isHidden = true
    }

  }

  func shouldShadeCell(_ shadingType: CellShadingType) {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
      return
    }
    let colors = appDelegate.userColors!
    switch shadingType {
    case .noClass:
      self.backgroundColor = colors.NoClassColor
      break
    case .studyHall:
      self.backgroundColor = colors.StudyHallColor
      break
    case .noShading:
      self.backgroundColor = UIColor.white
    }
  }
}

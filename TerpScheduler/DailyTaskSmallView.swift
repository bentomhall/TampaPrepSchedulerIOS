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
  
  weak var colors: UserColors?

  override func prepareForReuse() {
    topTaskLabel!.text = ""
    remainingTasksLabel!.text = ""
    remainingTasksLabel!.isHidden = false
  }

  func setTopTaskLabel(_ taskTitle: String, isTaskCompleted completion: Bool) {
    let nTitle = taskTitle as NSString
    if completion {
      topTaskLabel!.attributedText = NSAttributedString(string: taskTitle, attributes: [NSAttributedStringKey.strikethroughStyle: 2])
      topTaskLabel!.isEnabled = false
    } else {
      let text = NSMutableAttributedString(string: taskTitle)
      if taskTitle.lowercased().contains("test") || taskTitle.lowercased().contains("quiz") {
        let range = NSMakeRange(0, nTitle.length)
        text.addAttribute(NSAttributedStringKey.underlineStyle, value: 1, range: range)
      }
      topTaskLabel!.attributedText = text
      topTaskLabel!.isEnabled = true
    }
  }

  func setRemainingTasksLabel(tasksRemaining remaining: Int) {
    if remaining > 0 {
      remainingTasksLabel?.isHidden = false
      let text = "+ \(remaining) others"
      remainingTasksLabel!.text! = text
      if remaining > 1 {
        remainingTasksLabel!.textColor = colors!.primaryThemeColor
      } else if remaining == 1 {
        remainingTasksLabel!.text = "+ 1 other"
        remainingTasksLabel!.textColor = colors!.secondaryThemeColor
      }
    } else {
      remainingTasksLabel?.isHidden = true
    }

  }

  func shouldShadeCell(_ shadingType: CellShadingType) {
    topTaskLabel!.textColor = colors!.textColor
    switch shadingType {
    case .noClass:
      self.backgroundColor = colors!.NoClassColor
      break
    case .studyHall:
      self.backgroundColor = colors!.StudyHallColor
      break
    case .noShading:
      self.backgroundColor = colors!.cellColor
    }
  }
}

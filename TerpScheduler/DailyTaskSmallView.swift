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

enum AssessmentDecorationType {
  case None
  case Underline
  case TextColor
  case AllCaps
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

  func setTopTaskLabel(_ taskTitle: String, isTaskCompleted completion: Bool, decorationType: AssessmentDecorationType) {
    if completion {
      topTaskLabel!.attributedText = NSAttributedString(string: taskTitle, attributes: [NSAttributedStringKey.strikethroughStyle: 2])
      topTaskLabel!.isEnabled = false
    } else {
      let text = decorateText(text: taskTitle, decorationType: decorationType)
      topTaskLabel!.attributedText = text
      topTaskLabel!.isEnabled = true
    }
  }
  
  func decorateText(text: String, decorationType: AssessmentDecorationType) -> NSMutableAttributedString {
    let attributed = NSMutableAttributedString(string: text)
    if text.lowercased().contains("test") || text.lowercased().contains("quiz") {
      let range = NSMakeRange(0, (text as NSString).length)
      switch decorationType {
      case .None:
        break
      case .AllCaps:
        return NSMutableAttributedString(string: text.uppercased())
      case .TextColor:
        attributed.addAttribute(NSAttributedStringKey.backgroundColor, value: colors!.textHighlightColor, range: range)
        break
      case .Underline:
        attributed.addAttribute(NSAttributedStringKey.underlineStyle, value: 1, range: range)
        break
      }
    }
    return attributed
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

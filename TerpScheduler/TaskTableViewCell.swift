//
//  TaskCellTableViewCell.swift
//  TerpScheduler
//
//  Created by Ben Hall on 1/20/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell {

  @IBOutlet weak var title: UILabel?
  override func awakeFromNib() {
    super.awakeFromNib()
      // Initialization code
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

  }

  func setTitleText(_ text: String, taskIsComplete: Bool, colors: UserColors) {
    backgroundColor = colors.backgroundColor
    backgroundView?.backgroundColor = colors.backgroundColor
    selectedBackgroundView = UIView()
    selectedBackgroundView!.backgroundColor = colors.cellColor
    
    title!.text = text
    changeCompletionStatus(completion: taskIsComplete, colors: colors)

  }
    
    func changeCompletionStatus(completion: Bool, colors: UserColors) {
        if completion {
            textLabel!.textColor = colors.completedTaskTextColor
        } else {
            textLabel!.textColor = colors.textColor
        }
    }
}

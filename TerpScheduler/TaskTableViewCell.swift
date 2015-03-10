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

  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
  
  func setTitleText(text: String, taskIsComplete: Bool){
    title!.text = text
    if taskIsComplete {
      title!.textColor = UIColor.lightTextColor()
    }
  }
}

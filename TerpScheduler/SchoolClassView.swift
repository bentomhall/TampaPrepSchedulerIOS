//
//  SchoolClassView.swift
//  TerpScheduler
//
//  Created by Ben Hall on 1/5/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import UIKit

@IBDesignable
class SchoolClassView: UIView {

  @IBOutlet weak var classPeriodLabel: UILabel?
  @IBOutlet weak var classNameLabel: UILabel?
  @IBOutlet weak var teacherNameLabel: UILabel?

  var _classData: SchoolClass?
  var classData: SchoolClass {
    get { return _classData! }
    set(data) {
      _classData = data
      setContentLabels(data)
    }
  }

  var haikuURL: URL?

  func setContentLabels(_ data: SchoolClass) {
    classNameLabel!.text! = data.subject.uppercased()
    teacherNameLabel!.text! = data.teacherName
    haikuURL = data.haikuURL as URL?
  }
  
  func setColors(themeColors: UserColors) {
    self.backgroundColor = themeColors.cellColor
    DispatchQueue.main.async {
      self.teacherNameLabel!.textColor = themeColors.textColor
      self.classNameLabel!.textColor = themeColors.primaryThemeColor
    }
    
    
  }
}

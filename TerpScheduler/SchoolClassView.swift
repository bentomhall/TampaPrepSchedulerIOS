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
  
  @IBOutlet weak var ClassPeriodLabel : UILabel?
  @IBOutlet weak var ClassNameLabel : UILabel?
  @IBOutlet weak var TeacherNameLabel : UILabel?
  
  var _classData : SchoolClass?
  var classData : SchoolClass {
    get { return _classData! }
    set(data) {
      _classData = data
      SetContentLabels(data)
    }
  }
  
  var HaikuURL : NSURL?
  
  func SetContentLabels(data: SchoolClass){
    ClassNameLabel!.text! = data.subject
    ClassNameLabel!.text = ClassNameLabel!.text!.uppercaseString
    TeacherNameLabel!.text! = data.teacherName
    HaikuURL = data.haikuURL
  }
  
  /*
  // Only override drawRect: if you perform custom drawing.
  // An empty implementation adversely affects performance during animation.
  override func drawRect(rect: CGRect) {
  // Drawing code
  }
  */
  
}

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

    @IBOutlet var ClassPeriodLabel : UILabel?
    @IBOutlet var ClassNameLabel : UILabel?
    @IBOutlet var TeacherNameLabel : UILabel?
    var _classData : SchoolClass?
    var classData : SchoolClass {
        get { return _classData! }
        set(data) {
            _classData = data
            SetContentLabels(data)
        }
    }

    
    var isScheduleSet: Bool = false
    var HaikuURL : NSURL?
    
    func SetContentLabels(data: SchoolClass){
        ClassNameLabel!.text! = data.subject
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

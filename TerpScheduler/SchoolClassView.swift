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

    
    var isScheduleSet: Bool = false
    var HaikuURL : NSURL?
    
    func SetContentLabels(model: SchoolClassesModel){
        ClassPeriodLabel!.text! = String(model.ClassPeriod)
        ClassNameLabel!.text! = model.Subject
        TeacherNameLabel!.text! = model.TeacherName
        let url = model.HaikuURL
        if url != "" {
            HaikuURL = NSURL(string: url)
        }
        
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}

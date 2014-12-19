//
//  ClassPeriodView.swift
//  TerpScheduler
//
//  Created by Ben Hall on 12/18/14.
//  Copyright (c) 2014 Tampa Preparatory School. All rights reserved.
//

import UIKit

//@IBDesignable
class ClassPeriodViewController: UIViewController {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBOutlet var TeacherLabel: UILabel?
    @IBOutlet var PeriodLabel: UILabel?
    @IBOutlet var ClassName: UILabel?
    
    @IBAction func TapRecognizer(recognizer: UIGestureRecognizer){
        self.TeacherLabel?.text = "Test Teacher"
        return
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}

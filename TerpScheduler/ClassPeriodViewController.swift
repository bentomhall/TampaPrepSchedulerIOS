//
//  ClassPeriodView.swift
//  TerpScheduler
//
//  Created by Ben Hall on 12/18/14.
//  Copyright (c) 2014 Tampa Preparatory School. All rights reserved.
//

import UIKit

@IBDesignable
class ClassPeriodViewController: UIViewController {
    var receivedClassData : ClassPeriodData?
    var outputClassData : ClassPeriodData?
    var _classView : SchoolClassView?
    var classView : SchoolClassView? {
        get { return _classView }
        set(value) {
            _classView = value
            if value != nil {
                receivedClassData = value!.classData
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        let v = self.view as ClassPopupView
        println("\(v.subviews)")
        v.setContent(receivedClassData!)
    }
    
    override func viewWillDisappear(animated: Bool) {
        let v = self.view as ClassPopupView
        outputClassData = v.getContent()
        classView!.classData = outputClassData!
    }
}

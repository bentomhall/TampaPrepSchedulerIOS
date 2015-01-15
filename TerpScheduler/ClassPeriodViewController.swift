//
//  ClassPeriodView.swift
//  TerpScheduler
//
//  Created by Ben Hall on 12/18/14.
//  Copyright (c) 2014 Tampa Preparatory School. All rights reserved.
//

import UIKit

protocol ClassPeriodDataSource {
    func getClassData(period: Int)->ClassPeriodData
    func setClassData(data:ClassPeriodData, forIndex index:Int)
}

@IBDesignable
class ClassPeriodViewController: UIViewController {
    var receivedClassData : ClassPeriodData?
    var outputClassData : ClassPeriodData?
    var delegate : ClassPeriodDataSource?
    var _index: Int = -1
    var index : Int {
        get { return _index }
        set(value) {
            _index = value
            receivedClassData = delegate!.getClassData(index)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let v = self.view as ClassPopupView
        v.setContent(receivedClassData!)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        let v = self.view as ClassPopupView
        outputClassData = v.getContent()
        delegate!.setClassData(outputClassData!, forIndex: index)
    }
}

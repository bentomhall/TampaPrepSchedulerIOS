//
//  ClassPeriodView.swift
//  TerpScheduler
//
//  Created by Ben Hall on 12/18/14.
//  Copyright (c) 2014 Tampa Preparatory School. All rights reserved.
//

import UIKit

class ClassPeriodViewController: UIViewController {
    var classData : ClassPeriodData?
    
    override func viewDidLoad() {
        
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let classView = sender as? SchoolClassView{
        }
    }
}

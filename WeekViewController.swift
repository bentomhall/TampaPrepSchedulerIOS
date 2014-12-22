//
//  WeekViewController.swift
//  TerpScheduler
//
//  Created by Ben Hall on 12/19/14.
//  Copyright (c) 2014 Tampa Preparatory School. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class WeekViewController: UIViewController
{
    @IBOutlet weak var DayLabelBlock: DayLabelViewBlock?
    
    var weekID: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //actually, load this based on the week id
        let today = NSDate()
        DayLabelBlock!.SetDates(today)
    }
    
    func LoadNextWeek()
    {
        weekID += 1
        //switch out to next week
        return
    }
    
    func LoadPreviousWeek()
    {
        weekID -= 1
        //switch out to previous week
        LoadCurrentWeek()
    }
    
    func LoadCurrentWeek()
    {
        //called to populate the UI elements with current week's data
        return
    }
    
}

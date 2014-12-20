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
    var weekID: Int = 0
    var DayControllers: [DayLabelViewController] = []
    var TaskControllers: [TaskViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for o in self.childViewControllers.filter(isDayViewController) {
            DayControllers.append(o as DayLabelViewController)
        }
        for o in self.childViewControllers.filter(isTaskViewController) {
            TaskControllers.append(o as TaskViewController)
        }
        SetDates()
    }
    
    func isTaskViewController(o: AnyObject) ->Bool {
        return o is TaskViewController
    }
    
    func isDayViewController(o: AnyObject) -> Bool {
        return o is DayLabelViewController
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
    
    func SetDates(){
        let today = NSDate()
        let offset = NSDateComponents()
        
        for (index, dayView) in enumerate(self.DayControllers) {
            offset.day = index
            let todaysDate = NSCalendar.currentCalendar().dateByAddingComponents(offset, toDate: today , options: NSCalendarOptions.allZeros)
            dayView.SetDate(todaysDate!)
            dayView.SetScheduleType("A")
            }
    }
}

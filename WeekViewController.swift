//
//  WeekViewController.swift
//  TerpScheduler
//
//  Created by Ben Hall on 12/19/14.
//  Copyright (c) 2014 Tampa Preparatory School. All rights reserved.
//

import Foundation
import UIKit
import CoreData

@IBDesignable
class WeekViewController: UIViewController
{
    @IBOutlet weak var DayLabelBlock: DayLabelViewBlock?
    
    var weekID: Int = -1
    var WeekData : NSManagedObject?
    var delegate : AppDelegate?
    var managedObjectContext : NSManagedObjectContext?
    var childrenTableViewControllers : [DailyTasksTableViewController] = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = UIApplication.sharedApplication().delegate as? AppDelegate
        managedObjectContext = delegate!.managedObjectContext!
        LoadCurrentWeek()
        childrenTableViewControllers = self.childViewControllers as [DailyTasksTableViewController]
    }
    
    func FetchWeekID(today: NSDate) ->Int {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(NSCalendarUnit.CalendarUnitWeekOfYear, fromDate: today)
        return components.weekOfYear
    }
    
    func LoadNextWeek()
    {
        weekID += 1
        //switch out to next week
        LoadCurrentWeek()
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
        if weekID < 0 {
            let today = NSDate()
            weekID = FetchWeekID(today) //focus on current week
        }
        var fetchRequest = NSFetchRequest(entityName: "Week")
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = NSPredicate(format: "weekID = %i", weekID)
        var error : NSError?
        if let results = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [NSManagedObject]{
            WeekData = results[0]
            let firstDayString = WeekData!.valueForKey("firstWeekDay") as String
            let scheduleString = WeekData!.valueForKey("weekSchedules") as String
            let scheduleArray = scheduleString.componentsSeparatedByString(" ")
            var dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "M/dd/yyyy"
            let firstDay = dateFormatter.dateFromString(firstDayString)
            DayLabelBlock!.SetDates(firstDay!, schedule: scheduleArray)
        }
        return
    }
    
}

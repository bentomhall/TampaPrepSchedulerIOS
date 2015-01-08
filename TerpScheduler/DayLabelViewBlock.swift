//
//  DayLabelViewBlock.swift
//  TerpScheduler
//
//  Created by Ben Hall on 12/20/14.
//  Copyright (c) 2014 Tampa Preparatory School. All rights reserved.
//

import UIKit

@IBDesignable
class DayLabelViewBlock: UIView {
    
    @IBOutlet var DayLabels: [DayLabel]?
    
    func SetDates(date : NSDate, schedule : [String]){
        var offset = NSDateComponents()
        for (index, day) in enumerate(DayLabels!){
            offset.day = index
            let today = NSCalendar.currentCalendar().dateByAddingComponents(offset, toDate: date, options: NSCalendarOptions.allZeros)
            day.SetContents(date: today!, scheduleType: schedule[index])
        }
        
    }
    
}

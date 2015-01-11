//
//  dateHeaderView.swift
//  TerpScheduler
//
//  Created by Ben Hall on 1/11/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import UIKit

@IBDesignable
class dateHeaderView: UICollectionReusableView {
    @IBOutlet var dayLabels : [DayLabel]?
    
    func SetDates(date : NSDate, schedule : [String]){
        var offset = NSDateComponents()
        for (index, day) in enumerate(dayLabels!){
            offset.day = index
            let today = NSCalendar.currentCalendar().dateByAddingComponents(offset, toDate: date, options: NSCalendarOptions.allZeros)
            day.SetContents(date: today!, scheduleType: schedule[index])
        }
    }
}

//
//  dateHeaderView.swift
//  TerpScheduler
//
//  Created by Ben Hall on 1/11/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import UIKit

@IBDesignable
class DateHeaderView: UICollectionReusableView {
    @IBOutlet var dayLabels : [DayLabel]?
    
    func SetDates(dates : [SchoolDate]){
      let today = NSCalendar.currentCalendar().dateBySettingHour(0, minute: 0, second: 0, ofDate: NSDate(), options: NSCalendarOptions.allZeros)!
      for (index, date) in enumerate(dates) {
        let isToday = today.compare(date.Date) == NSComparisonResult.OrderedSame
        dayLabels![index].SetContents(date: date.Date, scheduleType: date.Schedule, dateIsToday: isToday)
      }
    }
}

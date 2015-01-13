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
        for (index, date) in enumerate(dates) {
            dayLabels![index].SetContents(date: date.Date, scheduleType: date.Schedule)
        }
    }
}

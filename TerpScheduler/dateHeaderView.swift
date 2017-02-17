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
  @IBOutlet var dayLabels: [DayLabel]?
  fileprivate let calendar = Calendar.current

  func SetDates(_ dates: [SchoolDate]) {
    let today = (calendar as NSCalendar).date(bySettingHour: 0, minute: 0, second: 0, of: Date(), options: NSCalendar.Options())!
    for (index, date) in dates.enumerated() {
      let isToday = today.compare(date.Date as Date) == ComparisonResult.orderedSame
      dayLabels![index].setContents(date: date.Date, scheduleType: date.Schedule, dateIsToday: isToday)
    }
  }
}

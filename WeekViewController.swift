//
//  WeekViewController.swift
//  TerpScheduler
//
//  Created by Ben Hall on 12/19/14.
//  Copyright (c) 2014 Tampa Preparatory School. All rights reserved.
//

import Foundation
import UIKit

class WeekViewController: UIViewController
{
    var weekID: Int = 0
    
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

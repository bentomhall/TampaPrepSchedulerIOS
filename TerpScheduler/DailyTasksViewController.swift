//
//  DailyTasksViewController.swift
//  TerpScheduler
//
//  Created by Ben Hall on 1/7/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class DailyTasksTableViewController: UITableViewController, UITableViewDelegate,
    UITableViewDataSource {
    
    var date : String = "" {
        willSet(dateString){
            if dateString != date {
              ReloadModel(dateString)
            }
        }
    }
    
    
    @IBOutlet var TableView : UITableView!
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func ReloadModel(dateString : String) {
        return
    }
}
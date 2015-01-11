//
//  ViewController.swift
//  TerpScheduler
//
//  Created by Ben Hall on 12/18/14.
//  Copyright (c) 2014 Tampa Preparatory School. All rights reserved.
//
import CoreData
import Foundation
import UIKit

class MainViewController: UIViewController {

    var delegate : AppDelegate?
    var context : NSManagedObjectContext?
    weak var dataSource = TaskCollectionDataSource()
    
    @IBOutlet var SchoolClassPeriodViews: [SchoolClassView]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        delegate = UIApplication.sharedApplication().delegate as? AppDelegate
        context = delegate!.managedObjectContext
        WeekController = self.childViewControllers[0] as? WeekViewController
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func TapGestureHandler(recognizer: UITapGestureRecognizer){
        let location = recognizer.locationInView(self.view)
        for subview in self.view.subviews {
            if subview.frame.contains(location) {
                println("Hit Object at \(location.x), \(location.y)")
                performSegueWithIdentifier("ClassesDetailPopup", sender: subview)
            }
            
        }
        //dummy
        return
    }
    
    @IBAction func SwipeRecognizer(recognizer: UISwipeGestureRecognizer){
        let direction = recognizer.direction
        switch (direction)
        {
            case UISwipeGestureRecognizerDirection.Left:
                break
                //open side pane
            case UISwipeGestureRecognizerDirection.Right:
                break
                //close side pane if open
            case UISwipeGestureRecognizerDirection.Up:
                //next week
                WeekController!.LoadNextWeek()
                break
            case UISwipeGestureRecognizerDirection.Down:
                //previous week
                WeekController!.LoadPreviousWeek()
                break
            default:
                //do nothing
                break
        }
    }


}


//
//  ViewController.swift
//  TerpScheduler
//
//  Created by Ben Hall on 12/18/14.
//  Copyright (c) 2014 Tampa Preparatory School. All rights reserved.
//
import CoreData
import UIKit

class MainViewController: UIViewController {

    var delegate : AppDelegate?
    var context : NSManagedObjectContext?
    weak var WeekController : WeekViewController?
    
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
    
    func LoadSemesterData(){
        let HasLoadedFetchRequest = NSFetchRequest(entityName: "AppData")
        var error : NSError?
        let appData = context?.executeFetchRequest(HasLoadedFetchRequest, error: &error) as [NSManagedObject]?
        let hasLoaded : Bool = appData?[0].valueForKey("hasLoaded") as Bool
        if !hasLoaded{
            //extract information from json file
            LoadScheduleDataFromJSON()
        }
    }
    
    func LoadScheduleDataFromJSON(){
        var error: NSError?
        let path = NSBundle.mainBundle().pathForResource("winter2015.json", ofType: "json")
        let data = NSData(contentsOfFile: path!)
        let jsonData : NSDictionary = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: &error) as NSDictionary
        for (key, value) in jsonData {
            let weekLabel = key as String
            let weekInformation = value as NSArray
            let weekSchedule = weekInformation[0] as [String]
            var dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "M/d/YYYY"
            let firstDay = dateFormatter.dateFromString(weekInformation[1] as String)
            let entity = NSEntityDescription.entityForName("Week", inManagedObjectContext: self.context!)
            var managedWeek = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: context!)
            managedWeek.setValue(weekLabel.toInt(), forKey: "weekID")
            managedWeek.setValue(SerializeSchedule(weekSchedule), forKey: "weekSchedules")
            managedWeek.setValue(firstDay, forKey: "firstWeekDay")
        }
    }
    
    func SerializeSchedule(schedule: [String])->String{
        return " ".join(schedule)
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


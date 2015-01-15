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

@IBDesignable
class MainViewController: UIViewController, UICollectionViewDataSource,
        UICollectionViewDelegate, UIPopoverPresentationControllerDelegate, ClassPeriodDataSource{

    var appDelegate : AppDelegate?
    var context : NSManagedObjectContext?
    @IBOutlet weak var collectionView : UICollectionView?
    @IBOutlet var classPeriods : [SchoolClassView]?
    var taskSummaries : [TaskSummaryData]?
    
    var taskRepository: TaskCollectionRepository?
    var dateRepository: DateHeaderRepository?
    var classRepository: SchoolClassesRepository?
    
    func getTaskSummariesForDatesBetween(startDate: NSDate, stopDate: NSDate){
        taskSummaries = taskRepository!.taskSummariesForDates(startDate, stopDate: stopDate)
    }
    
    //Mark - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        context = appDelegate!.managedObjectContext
        taskRepository = TaskCollectionRepository(context: context!)
        dateRepository = DateHeaderRepository(context: context!)
        classRepository = SchoolClassesRepository(appDelegate: appDelegate!)
        getTaskSummariesForDatesBetween(dateRepository!.firstDate, stopDate: dateRepository!.lastDate)
    }
    
    override func viewDidAppear(animated: Bool) {
        for (index, period) in enumerate(classPeriods!){
            let classData = classRepository!.GetClassDataByPeriod(index + 1)
            period.classData = classData
        }
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier!.hasPrefix("ClassDetail") {
            let index = segue.identifier!.componentsSeparatedByString("_")[1].toInt()
            var receivingController = segue.destinationViewController as ClassPeriodViewController
            receivingController.modalPresentationStyle = .Popover
            receivingController.popoverPresentationController?.delegate = self
            receivingController.preferredContentSize = CGSize(width: 300, height: 500)
            receivingController.delegate = self
            receivingController.index = index!
        }
        super.prepareForSegue(segue, sender: sender)
    }
    
    //MARK - ClassPeriodDataSource compliance
    func setClassData(data: ClassPeriodData, forIndex index:Int){
        classPeriods![index].classData = data
        classRepository!.SetClassModelFromData(data)
    }
    
    func getClassData(period: Int)->ClassPeriodData{
        return classPeriods![period].classData
    }
    
    //MARK - UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 35
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = self.collectionView!.dequeueReusableCellWithReuseIdentifier("ClassPeriodTaskSummary", forIndexPath: indexPath) as DailyTaskSmallView
        let summary = taskSummaries![0]// hack [indexPath.row]
        cell.setTopTaskLabel(summary.shortTitle)
        cell.setRemainingTasksLabel(summary.remainingTasks)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        var header = self.collectionView?.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "dateHeaderBlock", forIndexPath: indexPath) as DateHeaderView
        header.SetDates(dateRepository!.dates)
        return header
    }
    
    func reloadCollectionView(){
        collectionView!.reloadData()
    }
    
    
    
    @IBAction func SwipeRecognizer(recognizer: UISwipeGestureRecognizer){
        let direction = recognizer.direction
        switch (direction)
        {
            case UISwipeGestureRecognizerDirection.Left:
                dateRepository!.LoadPreviousWeek()
                getTaskSummariesForDatesBetween(dateRepository!.firstDate, stopDate: dateRepository!.lastDate)
                reloadCollectionView()
                break
            case UISwipeGestureRecognizerDirection.Right:
                dateRepository!.LoadNextWeek()
                getTaskSummariesForDatesBetween(dateRepository!.firstDate, stopDate: dateRepository!.lastDate)
                reloadCollectionView()
                break
            case UISwipeGestureRecognizerDirection.Up:
                break
            case UISwipeGestureRecognizerDirection.Down:
                break
            default:
                //do nothing
                break
        }
    }


}


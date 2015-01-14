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
        UICollectionViewDelegate, UIPopoverPresentationControllerDelegate{

    var delegate : AppDelegate?
    var context : NSManagedObjectContext?
    @IBOutlet weak var dataSource : TaskCollectionDataSource?
    @IBOutlet weak var collectionView : UICollectionView?
    @IBOutlet var classPeriods : [SchoolClassView]?
    var taskSummaries : [TaskSummaryData]?
    
    var taskRepository: TaskCollectionRepository?
    var dateRepository: DateHeaderRepository?
    var classRepository: SchoolClassesRepository?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        delegate = UIApplication.sharedApplication().delegate as? AppDelegate
        context = delegate!.managedObjectContext
        taskRepository = TaskCollectionRepository(context: context!)
        dateRepository = DateHeaderRepository(context: context!)
        classRepository = SchoolClassesRepository(context: context!)
        taskSummaries = taskRepository!.taskSummariesForDates(dateRepository!.firstDate, stopDate: dateRepository!.lastDate)
    }
    
    override func viewDidAppear(animated: Bool) {
        
        for (index, period) in enumerate(classPeriods!){
            let classData = classRepository!.GetClassDataByPeriod(index)
            period.classData = classData
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
    
    @IBAction func TapRecognizer(recognizer: UITapGestureRecognizer){
        performSegueWithIdentifier("ClassDetail_0", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (true){//segue.identifier!.hasPrefix("ClassDetail"){
            let index = segue.identifier!.componentsSeparatedByString("_")[1].toInt()
            var receivingController = segue.destinationViewController as ClassPeriodViewController
            var popoverController = UIPopoverPresentationController(presentedViewController: receivingController, presentingViewController: self)

            receivingController.classView = classPeriods![index!]
        }
    }


    
    @IBAction func SwipeRecognizer(recognizer: UISwipeGestureRecognizer){
        let direction = recognizer.direction
        switch (direction)
        {
            case UISwipeGestureRecognizerDirection.Left:
                break
            case UISwipeGestureRecognizerDirection.Right:
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


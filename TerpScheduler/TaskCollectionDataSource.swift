//
//  TaskCollectionDataSource.swift
//  TerpScheduler
//
//  Created by Ben Hall on 1/11/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import UIKit
import CoreData

class TaskCollectionDataSource: UICollectionViewController, UICollectionViewDataSource,
    UICollectionViewDelegate {
    
    var taskRepository : TaskCollectionRepository?
    var taskSummaries : [TaskSummaryData] = []
    var dateRepository : DateHeaderRepository?
    
    func setRepositories(taskRepository taskRepo: TaskCollectionRepository, withDateHeaderRepository dateRepo: DateHeaderRepository){
        taskRepository = taskRepo
        dateRepository = dateRepo
        taskSummaries = taskRepo.taskSummariesForDates(dateRepository!.firstDate, stopDate: dateRepository!.lastDate)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
   
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 42
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = self.collectionView!.dequeueReusableCellWithReuseIdentifier("ClassPeriodTaskSummary", forIndexPath: indexPath) as DailyTaskSmallView
        let summary = taskSummaries[indexPath.row]
        cell.setTopTaskLabel(summary.shortTitle)
        cell.setRemainingTasksLabel(summary.remainingTasks)
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        var header = self.collectionView?.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "DateHeaderBlock", forIndexPath: indexPath) as DateHeaderView
        header.SetDates(dateRepository!.dates)
        return header
    }
    
    
    
}

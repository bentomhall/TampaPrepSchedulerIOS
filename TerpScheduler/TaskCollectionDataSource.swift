//
//  TaskCollectionDataSource.swift
//  TerpScheduler
//
//  Created by Ben Hall on 1/11/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import UIKit
import CoreData

class TaskCollectionDataSource: NSObject, UICollectionViewDataSource,
    UICollectionViewDelegate {
    
    @IBOutlet var dateHeader : dateHeaderView?
    var taskRepository : DailyTasksCollection
    var classPeriods : SchoolClassesRepository
    var indexesForClassPeriods : [NSIndexPath] = []
    
    init(taskRepository taskRepo: DailyTasksCollection, withClassRepository classRepo: SchoolClassesRepository){
        taskRepository = taskRepo
        classPeriods = classRepo
        for indx in 0...41{
            if indx % 7 == 0 {
                indexesForClassPeriods.append(NSIndexPath(forItem: indx, inSection: 0))
            }
        }
    }
   
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 42
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        return UICollectionReusableView()
    }
    
    
    
}

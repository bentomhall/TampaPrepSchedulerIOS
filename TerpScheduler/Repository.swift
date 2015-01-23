//
//  GenericRepository.swift
//  TerpScheduler
//
//  Created by Ben Hall on 1/21/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import UIKit
import CoreData

func dateRange(start: NSDate, stop: NSDate)->[NSDate]{
  var dates: [NSDate] = []
  var currentDate = start
  while currentDate.compare(stop) != NSComparisonResult.OrderedDescending{
    dates.append(currentDate)
    currentDate = NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.CalendarUnitDay, value: 1, toDate: currentDate, options: NSCalendarOptions.allZeros)!
  }
  return dates
}

enum RepositoryFilterType {
  case byDate
  case byPeriod
  case byID
  case byDateAndPeriod
  case byDateAndPeriodAndID
  case byDateBetween
  case byTitleIsEmpty
}

struct FilterValues: Filterable {
  var date: NSDate
  var period: Int
  var id: NSManagedObjectID
  var stopDate: NSDate?
  var shortTitle: String
}

extension FilterValues {
  init(fromFilterable: Filterable){
    self.date = fromFilterable.date
    self.id = fromFilterable.id
    self.period = fromFilterable.period
    self.shortTitle = fromFilterable.shortTitle
  }
  
  init(optDate: NSDate?, optID: NSManagedObjectID?, optPeriod: Int?, optTitle: String?){
    self.date = optDate ?? NSDate()
    self.id = optID ?? NSManagedObjectID()
    self.period = optPeriod ?? -1
    self.shortTitle = optTitle ?? "_"
  }
}

protocol Filterable {
  var date: NSDate { get }
  var period: Int { get }
  var id: NSManagedObjectID { get }
  var shortTitle: String { get }
}

protocol DataObject {
  init(entity: NSManagedObject)
  func toEntity(inContext context: NSManagedObjectContext)->NSManagedObject
}


class Repository<T: protocol<Filterable, DataObject>, U: NSManagedObject> {
  private func newFetchRequestforEntity(entity: String)->NSFetchRequest{
    return NSFetchRequest(entityName: entity)
  }
  
  private let entityName: String
  private var _cache = [T]()
  private var context: NSManagedObjectContext?
  func search(items: [T], predicate: RepositoryFilterType, values: FilterValues)->[T]{
    var results = [T]()
    for item in items {
      let dateComparison = item.date.compare(values.date) == .OrderedSame
      let periodComparison = item.period == values.period
      let idComparison = item.id == values.id
      
      switch (predicate) {
      case .byDate:
        if dateComparison {
          results.append(item)
        }
        break
      case .byPeriod:
        if periodComparison {
          results.append(item)
        }
        break
      case .byID:
        if idComparison {
          results.append(item)
        }
        break
      case .byDateAndPeriod:
        if (dateComparison && periodComparison){
          results.append(item)
        }
        break
      case .byDateAndPeriodAndID:
        if (dateComparison && periodComparison && idComparison){
          results.append(item)
        }
      case .byDateBetween:
        assert(values.stopDate != nil, "Must set stopDate for multi-date filtering")
        if dateComparison {
          results.append(item)
        } else {
          if (item.date.compare(values.date) == .OrderedAscending && item.date.compare(values.stopDate!) == .OrderedDescending) {
            results.append(item)
          }
        }
      case .byTitleIsEmpty:
        if item.shortTitle == "" {
          results.append(item)
        }
      default:
        break
      }
    }
    return results
  }
  private func predicateByType(type: RepositoryFilterType, value: FilterValues)->NSPredicate {
    var p: NSPredicate?
    switch(type){
    case .byDate:
      p = NSPredicate(format: "dateDue = %@", value.date)
      break
    case .byID:
      p = NSPredicate(format: "id = %@", value.id)
      break
    case .byPeriod:
      p = NSPredicate(format: "forPeriod = %i", value.period)
      break
    case .byDateAndPeriod:
      let p1 = NSPredicate(format: "dateDue = %@", value.date)
      let p2 = NSPredicate(format: "forPeriod = %i", value.period)
      p = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [p1!, p2!])
      break
    case .byDateAndPeriodAndID:
      let p1 = NSPredicate(format: "dateDue = %@", value.date)
      let p2 = NSPredicate(format: "forPeriod = %i", value.period)
      let p3 = NSPredicate(format: "id = %@", value.id)
      p = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [p1!, p2!, p3!])
      break
    case .byDateBetween:
      p = NSPredicate(format: "date > %@ and date < %@", argumentArray: [value.date, value.stopDate!])
    case .byTitleIsEmpty:
      p = NSPredicate(format: "shortTitle = %@", String())
    }
    return p!
  }
  private func fetchAll()->[T]{
    let fetchRequest = newFetchRequestforEntity(entityName)
    fetchRequest.predicate = NSPredicate(value: true)
    let results = context!.executeFetchRequest(fetchRequest, error: nil) as [U]
    let data = dataFromEntities(results)
    return data
  }

  init(entityName: String, withContext context: NSManagedObjectContext){
    self.entityName = entityName
    //fetchRequest = newFetchRequestforEntity(entityName)
    //fetchRequest!.returnsDistinctResults = true
    //fetchRequest!.returnsObjectsAsFaults = false
    self.context = context
    _cache = fetchAll()
  }
  
  func fetchBy(type: RepositoryFilterType, values: FilterValues)->[T]{
    let fetchRequest = newFetchRequestforEntity(entityName)
    let cacheResults = search(_cache, predicate:type, values: values)
    if cacheResults.count > 0 {
      return cacheResults
    } else {
      fetchRequest.predicate = predicateByType(type, value: values)
      if let results = context!.executeFetchRequest(fetchRequest, error: nil) as? [U]{
        let data = dataFromEntities(results)
        _cache.extend(data)
        return data
      }
    }
    return [T]()
  }
  
  private func dataFromEntities(entities: [U])->[T]{
    var answer = [T]()
    for item in entities{
      answer.append(T(entity: item))
    }
    return answer
  }
  
  func deleteItemMatching(values filter: protocol<Filterable, DataObject>){
    func getIndex(filter: Filterable, isDefault: Bool)->Int{
      for (index, item) in enumerate(_cache) {
        if isDefault {
          if item.shortTitle == "" {
            return index
          }
        } else {
          if filter.id == item.id {
            return index
          }
        }
      }
        return -1
    }
    var cacheIndex = -1
    if filter.shortTitle == ""{
      cacheIndex = getIndex(filter, true)
    } else {
      cacheIndex = getIndex(filter, false)
    }
    if cacheIndex >= 0 {
      _cache.removeAtIndex(cacheIndex)
    }
    var error: NSError?
    let allItems = fetchAll()
    let itemToDelete = filter.toEntity(inContext: context!) as U
    context!.deleteObject(filter.toEntity(inContext: context!))
    context!.save(&error)
  }
  
  func add(item: T, entity: U){
    _cache.append(item)
    context!.insertObject(entity)
    context!.save(nil)
  }
  
  func fetchDefault(){
    
  }

}
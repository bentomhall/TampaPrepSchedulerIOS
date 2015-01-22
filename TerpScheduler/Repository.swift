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
}

struct FilterValues: Filterable {
  var date: NSDate = NSDate()
  var period: Int = 0
  var id: NSUUID = NSUUID()
  var stopDate: NSDate?
}

extension FilterValues {
  init(fromFilterable: Filterable){
    self.date = fromFilterable.date
    self.id = fromFilterable.id
    self.period = fromFilterable.period
  }
}

protocol Filterable {
  var date: NSDate { get }
  var period: Int { get }
  var id: NSUUID { get }
}

protocol DataObject {
  init(entity: NSManagedObject)
}


class Repository<T: protocol<Filterable, DataObject>> {
  private func newFetchRequestforEntity(entity: String)->NSFetchRequest{
    return NSFetchRequest(entityName: entity)
  }
  
  private var _cache = [T]()
  private var fetchRequest: NSFetchRequest?
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
    }
    return p!
  }

  init(entityName: String, withContext context: NSManagedObjectContext){
    fetchRequest = newFetchRequestforEntity(entityName)
    self.context = context
  }
  
  func fetchBy(type: RepositoryFilterType, values: FilterValues)->[T]{
    let cacheResults = search(_cache, predicate:type, values: values)
    if cacheResults.count > 0 {
      return cacheResults
    } else {
      fetchRequest!.predicate = predicateByType(type, value: values)
      if let results = context!.executeFetchRequest(fetchRequest!, error: nil) as? [NSManagedObject]{
        let data = dataFromEntities(results)
        _cache.extend(data)
        return data
      }
    }
    return [T]()
  }
  
  private func dataFromEntities(entities: [NSManagedObject])->[T]{
    var answer = [T]()
    for item in entities{
      answer.append(T(entity: item))
    }
    return answer
  }
  
  func deleteItemMatching(values filter: Filterable){
    func getIndex(filter: Filterable)->Int{
      for (index, item) in enumerate(_cache) {
        if filter.date.compare(item.date) == .OrderedSame && filter.period == item.period && filter.id == item.id {
          return index
        }
      }
        return -1
    }
    _cache.removeAtIndex(getIndex(filter))
    fetchRequest!.predicate = predicateByType(RepositoryFilterType.byDateAndPeriodAndID, value: FilterValues(fromFilterable: filter))
    if let results = context!.executeFetchRequest(fetchRequest!, error: nil) as? [NSManagedObject]{
      if results.count > 0 {
        context!.deleteObject(results[0])
      }
    }
  }
  
  func add(item: T){
    _cache.append(item)
    context!.save(nil)
  }

}
//
//  GenericRepository.swift
//  TerpScheduler
//
//  Created by Ben Hall on 1/21/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import Foundation
import CoreData

enum RepositoryFilterType {
  case byDate
  case byPeriod
  case ByID
  case byDateAndPeriod
  case byDateAndPeriodAndID
  case byDateBetween
}

struct FilterValues: Filterable {
  var date: NSDate
  var period: Int
  var id: Int
  var stopDate: NSDate?
  
}

protocol Filterable {
  var date: NSDate { get }
  var period: Int { get }
  var id: Int { get }
}

class GenericRepository<T: Filterable> {
  private func newFetchRequestforEntity(entity: String)->NSFetchRequest{
    return NSFetchRequest(entityName: entity)
  }
  
  private var _cache = [T]()
  private var fetchRequest: NSFetchRequest?
  private var context: NSManagedObjectContext?
  private func searchCache(predicate: RepositoryFilterType, values: FilterValues)->[T]{
    var results = [T]()
    for item in _cache {
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
      case .ByID:
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
      p = NSPredicate(format: "date = %@", value.date)
      break
    case .ByID:
      p = NSPredicate(format: "id = %@", value.id)
      break
    case .byPeriod:
      p = NSPredicate(format: "period = %@", value.period)
      break
    case .byDateAndPeriod:
      let p1 = NSPredicate(format: "date = %@", value.date)
      let p2 = NSPredicate(format: "period = %@", value.period)
      p = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [p1!, p2!])
      break
    case .byDateAndPeriodAndID:
      let p1 = NSPredicate(format: "date = %@", value.date)
      let p2 = NSPredicate(format: "period = %@", value.period)
      let p3 = NSPredicate(format: "id = %@", value.id)
      p = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [p1!, p2!, p3!])
      break
    case .byDateBetween:
      p = NSPredicate(format: "date > %@ and date < %@", argumentArray: [value.date, value.stopDate!])
    }
    return p!
  }
  private func dataFromModels(models: [NSManagedObject])->[T]?{
    //required to override
    return nil
  }
  private func entityFromData(data: T)->NSManagedObject?{
    //override me!
    return nil
  }
  
  init(entityName: String, withContext context: NSManagedObjectContext){
    fetchRequest = newFetchRequestforEntity(entityName)
    self.context = context
  }
  
  func filterBy(type: RepositoryFilterType, values: FilterValues)->[T]{
    let cacheResults = searchCache(type, values: values)
    if cacheResults.count > 0 {
      return cacheResults
    } else {
      fetchRequest!.predicate = predicateByType(type, value: values)
      if let results = context!.executeFetchRequest(fetchRequest!, error: nil) as? [NSManagedObject]{
        return dataFromModels(results)! // will break if dataFromModels not overridden
      }
    }
    return [T]()
  }
  
  func persistData(data: T){
    //overrideß me!
  }
  
  
}
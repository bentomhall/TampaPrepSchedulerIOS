//
//  GenericRepository.swift
//  TerpScheduler
//
//  Created by Ben Hall on 1/21/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import UIKit
import CoreData

/// Generates a list of dates between the two provided dates. Includes the start date **but not the stop date**.
///
/// - Parameters:
///   - start: The first date to include.
///   - stop:  The first date **not** to include.
/// - Returns: A list of dates matching the criteria.
func dateRange(_ start: Date, stop: Date) -> [Date] {
    var dates: [Date] = []
    var currentDate = start
    while currentDate.compare(stop) != ComparisonResult.orderedDescending {
        dates.append(currentDate)
        currentDate = (Calendar.current as NSCalendar).date(byAdding: NSCalendar.Unit.day, value: 1, to: currentDate, options: NSCalendar.Options())!
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
    var date: Date
    var period: Int
    var id: NSManagedObjectID?
    var stopDate: Date?
    var shortTitle: String
    var GUID: String?
}

extension FilterValues {
    init(fromFilterable: Filterable) {
        self.date = fromFilterable.date
        self.id = fromFilterable.id
        self.period = fromFilterable.period
        self.shortTitle = fromFilterable.shortTitle
        self.GUID = fromFilterable.GUID
    }
    
    init(optDate: Date?, optID: NSManagedObjectID?, optPeriod: Int?, optTitle: String?, optGUID: String?) {
        self.date = optDate ?? Date()
        self.id = optID ?? NSManagedObjectID()
        self.period = optPeriod ?? -1
        self.shortTitle = optTitle ?? "_"
        self.GUID = optGUID ?? UUID().uuidString
    }
}

protocol Filterable {
    var date: Date { get }
    var period: Int { get }
    var id: NSManagedObjectID? { get }
    var GUID: String? { get }
    var shortTitle: String { get }
}

protocol DataObject {
    init(entity: NSManagedObject)
    func toEntity(inContext context: NSManagedObjectContext, isNew: Bool) -> NSManagedObject
}

/// Base generic repository. Handles filtering and fetching.
class Repository<T: Filterable & DataObject, U: NSManagedObject> {
    init(entityName: String, withContext context: NSManagedObjectContext) {
        self.entityName = entityName
        self.context = context
    }
    
    fileprivate func newFetchRequest()->NSFetchRequest<NSFetchRequestResult> {
        return NSFetchRequest(entityName: entityName)
    }
    
    fileprivate func dataFromEntities(_ entities: [U]) -> [T] {
        var answer = [T]()
        for item in entities {
            answer.append(T(entity: item))
        }
        return answer
    }
    
    fileprivate let entityName: String
    fileprivate var context: NSManagedObjectContext?
    fileprivate func predicateByType(_ type: RepositoryFilterType, value: FilterValues) -> NSPredicate {
        var p: NSPredicate?
        switch type {
        case .byDate:
            p = NSPredicate(format: "dateDue = %@", value.date as CVarArg)
            break
        case .byID:
            p = NSPredicate(format: "guid = %@", value.GUID! as CVarArg)
            break
        case .byPeriod:
            p = NSPredicate(format: "forPeriod = %i", value.period)
            break
        case .byDateAndPeriod:
            let p1 = NSPredicate(format: "dateDue = %@", value.date as CVarArg)
            let p2 = NSPredicate(format: "forPeriod = %i", value.period)
            p = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [p1, p2])
            break
        case .byDateAndPeriodAndID:
            let p1 = NSPredicate(format: "dateDue = %@", value.date as CVarArg)
            let p2 = NSPredicate(format: "forPeriod = %i", value.period)
            let p3 = NSPredicate(format: "guid = %@", value.GUID! as CVarArg)
            p = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [p1, p2, p3])
            break
        case .byDateBetween:
            p = NSPredicate(format: "date > %@ and date < %@", argumentArray: [value.date, value.stopDate!])
        case .byTitleIsEmpty:
            p = NSPredicate(format: "shortTitle = %@", String())
        }
        return p!
    }
    
    /// Get all results of a type.
    ///
    /// - Returns: All matching results. Empty list on error or nothing found.
    func fetchAll() -> [T] {
        let fetchRequest = newFetchRequest()
        fetchRequest.predicate = NSPredicate(value: true)
        let results = try? context!.fetch(fetchRequest) as? [U]
        if results != nil {
            let data = dataFromEntities(results!)
            return data
        } else {
            return [T]()
        }
    }
    
    /// Fetches a single `T` by GUID. Only *really* works for `T` = `DailyTask`, as none of the others have GUID entries.
    ///
    /// - Parameter byGUID: The GUID for the item to search for.
    /// - Returns: The managed object matching the request GUID.
    func fetchForUpdate(byGUID: String?) -> U? {
        let fetchRequest = newFetchRequest()
        fetchRequest.predicate = NSPredicate(format: "guid = %@", byGUID! as CVarArg)
        let results = try? context!.fetch(fetchRequest)
        if results != nil {
            if results!.count > 0 {
                return results![0] as? U
            }
        }
        return nil
    }
    
    /// Saves the context. Logs errors, does not re-throw.
    /// TODO: Fix this to actually throw properly.
    func save() {
        var error: NSError?
        do {
            try context!.save()
        } catch let error1 as NSError {
            error = error1
        }
        if error != nil {
            NSLog("%@", error!)
        }
    }
    
    ///fetches all stored items matching the values given when filtered by type
    ///
    ///- Parameter type: RepositoryFilterType value on which to filter.
    ///- Parameter values: Set of values to match against. Only the one matching the filter type will be used.
    ///- Returns: list of values matching filter criteria
    func fetchBy(_ type: RepositoryFilterType, values: FilterValues) -> [T] {
        let fetchRequest = newFetchRequest()
        fetchRequest.predicate = predicateByType(type, value: values)
        if let results = try? context!.fetch(fetchRequest) as? [U] {
            let data = dataFromEntities(results)
            return data
        }
        return [T]()
    }
    
    /// Deletes the item matching the provided filter. Saves the context afterward.
    ///
    /// - Parameter filter: The `Filterable` data object to remove from the store.
    func deleteItemMatching(values filter: Filterable & DataObject) {
        var toDelete: NSManagedObject?
        toDelete = try? context!.existingObject(with: filter.id!)
        if toDelete != nil {
            context!.delete(toDelete!)
        }
        save()
    }
    
    /// Adds a `T` to the store and saves the context.
    ///
    /// - Parameter item: The item to be stored.
    func add(_ item: T) {
        let _ = item.toEntity(inContext: context!, isNew: true)
        save()
    }
    
    /// Adds a `T` to the store. Does not save. Used for bulk saves (as intermediate saves are slower).
    ///
    /// - Parameter item: The entity to be stored.
    func addWithoutSave(_ item: T) {
        let _ = item.toEntity(inContext: context!, isNew: true)
    }
}

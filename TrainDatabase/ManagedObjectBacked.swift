//
//  ManagedObjectBacked.swift
//  TrainDatabase
//
//  Created by Scott James Remnant on 12/19/17.
//  Copyright © 2017 Scott James Remnant. All rights reserved.
//

import Foundation
import CoreData

protocol ManagedObjectBacked : Hashable {
    
    associatedtype ManagedObjectType : NSManagedObject
    
    var managedObject: ManagedObjectType { get set }
    
    init(managedObject: ManagedObjectType)
    init(context: NSManagedObjectContext)
    
}


extension ManagedObjectBacked {
    
    static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.managedObject.objectID == rhs.managedObject.objectID
    }
    
    var hashValue: Int {
        return managedObject.hashValue
    }

    func sortedValues<T: NSManagedObject>(from entity: T.Type, for key: String, ascending: Bool, startingWith string: String? = nil) throws -> [String] {
        guard let context = managedObject.managedObjectContext else { fatalError("No context to make query with") }
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = T.fetchRequest()
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.returnsDistinctResults = true
        fetchRequest.propertiesToFetch = [ key ]
        fetchRequest.sortDescriptors = [ NSSortDescriptor(key: key, ascending: ascending) ]
        
        var predicates: [NSPredicate] = []
        predicates.append(NSPredicate(format: "\(key) != ''"))
        
        if let string = string {
            predicates.append(NSPredicate(format: "\(key) BEGINSWITH[c] %@", string))
        }
        
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        let results = try context.fetch(fetchRequest) as! [[String: String]]
        return results.map({ $0[key]! })
    }

    func sortedValues(for key: String, ascending: Bool, startingWith string: String? = nil) throws -> [String] {
        return try sortedValues(from: ManagedObjectType.self, for: key, ascending: ascending, startingWith: string)
    }

    static func changed(in notification: Notification) -> (inserted: Set<Self>, updated: Set<Self>, deleted: Set<Self>) {
        var inserted: Set<Self> = Set()
        if let insertedObjects = notification.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject> {
            inserted.formUnion(insertedObjects.filter({ $0.entity == ManagedObjectType.entity() }).map({ Self.init(managedObject: $0 as! ManagedObjectType) }))
        }
        
        var updated: Set<Self> = Set()
        if let updatedObjects = notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject> {
            updated.formUnion(updatedObjects.filter({ $0.entity == ManagedObjectType.entity() }).map({ Self.init(managedObject: $0 as! ManagedObjectType) }))
        }
        
        var deleted: Set<Self> = Set()
        if let deletedObjects = notification.userInfo?[NSDeletedObjectsKey] as? Set<NSManagedObject> {
            deleted.formUnion(deletedObjects.filter({ $0.entity == ManagedObjectType.entity() }).map({ Self.init(managedObject: $0 as! ManagedObjectType) }))
        }
        
        return (inserted, updated, deleted)
    }
    
}


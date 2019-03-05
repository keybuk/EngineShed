//
//  Purchase+Suggestions.swift
//  EngineShed
//
//  Created by Scott James Remnant on 3/4/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import CoreData

extension Purchase {

    public func suggestionsForManufacturer(startingWith prefix: String? = nil) -> [String] {
        guard let managedObjectContext = managedObjectContext else { return [] }

        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Purchase.fetchRequest()
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.propertiesToFetch = [ "manufacturer" ]
        fetchRequest.returnsDistinctResults = true
        fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "manufacturer", ascending: true) ]

        if let prefix = prefix {
            fetchRequest.predicate = NSPredicate(format: "manufacturer BEGINSWITH %@", prefix)
        }

        let results = (try? managedObjectContext.performAndWait {
            return try fetchRequest.execute() as! [[String: String]]
        }) ?? []

        return results.compactMap { $0["manufacturer"] }
    }

    public func suggestionsForStore(startingWith prefix: String? = nil) -> [String] {
        guard let managedObjectContext = managedObjectContext else { return [] }

        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Purchase.fetchRequest()
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.propertiesToFetch = [ "store" ]
        fetchRequest.returnsDistinctResults = true
        fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "store", ascending: true) ]

        if let prefix = prefix {
            fetchRequest.predicate = NSPredicate(format: "store BEGINSWITH %@", prefix)
        }

        let results = (try? managedObjectContext.performAndWait {
            return try fetchRequest.execute() as! [[String: String]]
        }) ?? []

        return results.compactMap { $0["store"] }
    }

}

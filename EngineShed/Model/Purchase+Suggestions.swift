//
//  Purchase+Suggestions.swift
//  EngineShed
//
//  Created by Scott James Remnant on 3/4/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation
import CoreData

extension Purchase {

    func suggestionsForManufacturer(startingWith prefix: String? = nil) -> [String] {
        guard let managedObjectContext = managedObjectContext else { return [] }

        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Purchase.fetchRequest()
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.propertiesToFetch = [ "manufacturer" ]
        fetchRequest.returnsDistinctResults = true
        fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "manufacturer", ascending: true) ]

        if let prefix = prefix, !prefix.isEmpty {
            fetchRequest.predicate = NSPredicate(format: "manufacturer BEGINSWITH %@", prefix)
        } else {
            fetchRequest.predicate = NSPredicate(format: "manufacturer != NULL AND manufacturer != ''")
        }

        let results = (try? managedObjectContext.performAndWait {
            return try fetchRequest.execute() as! [[String: String]]
        }) ?? []

        return results.compactMap { $0["manufacturer"] }
    }

    func suggestionsForStore(startingWith prefix: String? = nil) -> [String] {
        guard let managedObjectContext = managedObjectContext else { return [] }

        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Purchase.fetchRequest()
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.propertiesToFetch = [ "store" ]
        fetchRequest.returnsDistinctResults = true
        fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "store", ascending: true) ]

        if let prefix = prefix, !prefix.isEmpty {
            fetchRequest.predicate = NSPredicate(format: "store BEGINSWITH %@", prefix)
        } else {
            fetchRequest.predicate = NSPredicate(format: "store != NULL AND storestore != ''")
        }

        let results = (try? managedObjectContext.performAndWait {
            return try fetchRequest.execute() as! [[String: String]]
        }) ?? []

        return results.compactMap { $0["store"] }
    }

}

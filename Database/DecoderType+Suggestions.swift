//
//  DecoderType+Suggestions.swift
//  EngineShed
//
//  Created by Scott James Remnant on 3/6/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation
import CoreData

extension DecoderType {

    public func suggestionsForManufacturer(startingWith prefix: String? = nil) -> [String] {
        guard let managedObjectContext = managedObjectContext else { return [] }

        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = DecoderType.fetchRequest()
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

    public func suggestionsForSocket(startingWith prefix: String? = nil) -> [String] {
        guard let managedObjectContext = managedObjectContext else { return [] }

        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = DecoderType.fetchRequest()
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.propertiesToFetch = [ "socket" ]
        fetchRequest.returnsDistinctResults = true
        fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "socket", ascending: true) ]

        if let prefix = prefix {
            fetchRequest.predicate = NSPredicate(format: "socket BEGINSWITH %@", prefix)
        }

        let results = (try? managedObjectContext.performAndWait {
            return try fetchRequest.execute() as! [[String: String]]
            }) ?? []

        return results.compactMap { $0["socket"] }
    }

}
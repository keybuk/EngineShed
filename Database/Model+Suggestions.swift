//
//  Model+Suggestions.swift
//  EngineShed
//
//  Created by Scott James Remnant on 3/9/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation
import CoreData

extension Model {

    public func suggestionsForClass(startingWith prefix: String? = nil) -> [String] {
        guard let managedObjectContext = managedObjectContext else { return [] }

        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Model.fetchRequest()
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.propertiesToFetch = [ "modelClass" ]
        fetchRequest.returnsDistinctResults = true
        fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "modelClass", ascending: true) ]

        if let prefix = prefix, !prefix.isEmpty {
            fetchRequest.predicate = NSPredicate(format: "modelClass BEGINSWITH %@", prefix)
        } else {
            fetchRequest.predicate = NSPredicate(format: "modelClass != NULL AND modelClass != ''")
        }

        let results = (try? managedObjectContext.performAndWait {
            return try fetchRequest.execute() as! [[String: String]]
            }) ?? []

        return results.compactMap { $0["modelClass"] }
    }

    public func suggestionsForLivery(startingWith prefix: String? = nil) -> [String] {
        guard let managedObjectContext = managedObjectContext else { return [] }

        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Model.fetchRequest()
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.propertiesToFetch = [ "livery" ]
        fetchRequest.returnsDistinctResults = true
        fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "livery", ascending: true) ]

        if let prefix = prefix, !prefix.isEmpty {
            fetchRequest.predicate = NSPredicate(format: "livery BEGINSWITH %@", prefix)
        } else {
            fetchRequest.predicate = NSPredicate(format: "livery != NULL AND livery != ''")
        }

        let results = (try? managedObjectContext.performAndWait {
            return try fetchRequest.execute() as! [[String: String]]
            }) ?? []

        return results.compactMap { $0["livery"] }
    }

}

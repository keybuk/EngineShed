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

    func suggestionsForClass(startingWith prefix: String? = nil) -> [String] {
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

    func suggestionsForLivery(startingWith prefix: String? = nil) -> [String] {
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
    
    func suggestionsForMotor(startingWith prefix: String? = nil) -> [String] {
        guard let managedObjectContext = managedObjectContext else { return [] }

        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Model.fetchRequest()
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.propertiesToFetch = [ "motor" ]
        fetchRequest.returnsDistinctResults = true
        fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "motor", ascending: true) ]

        if let prefix = prefix, !prefix.isEmpty {
            fetchRequest.predicate = NSPredicate(format: "motor BEGINSWITH %@", prefix)
        } else {
            fetchRequest.predicate = NSPredicate(format: "motor != NULL AND motor != ''")
        }

        let results = (try? managedObjectContext.performAndWait {
            return try fetchRequest.execute() as! [[String: String]]
            }) ?? []

        return results.compactMap { $0["motor"] }
    }

    func suggestionsForSocket(startingWith prefix: String? = nil) -> [String] {
        guard let managedObjectContext = managedObjectContext else { return [] }

        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Model.fetchRequest()
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.propertiesToFetch = [ "socket" ]
        fetchRequest.returnsDistinctResults = true
        fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "socket", ascending: true) ]

        if let prefix = prefix, !prefix.isEmpty {
            fetchRequest.predicate = NSPredicate(format: "socket BEGINSWITH %@", prefix)
        } else {
            fetchRequest.predicate = NSPredicate(format: "socket != NULL AND socket != ''")
        }

        let results = (try? managedObjectContext.performAndWait {
            return try fetchRequest.execute() as! [[String: String]]
            }) ?? []

        return results.compactMap { $0["socket"] }
    }

    func suggestionsForSpeaker(startingWith prefix: String? = nil) -> [String] {
        guard let managedObjectContext = managedObjectContext else { return [] }

        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Model.fetchRequest()
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.propertiesToFetch = [ "speaker" ]
        fetchRequest.returnsDistinctResults = true
        fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "speaker", ascending: true) ]

        if let prefix = prefix, !prefix.isEmpty {
            fetchRequest.predicate = NSPredicate(format: "speaker BEGINSWITH %@", prefix)
        } else {
            fetchRequest.predicate = NSPredicate(format: "speaker != NULL AND speaker != ''")
        }

        let results = (try? managedObjectContext.performAndWait {
            return try fetchRequest.execute() as! [[String: String]]
            }) ?? []

        return results.compactMap { $0["speaker"] }
    }

    // MARK: List suggestions

    func suggestionsForLights(startingWith prefix: String? = nil) -> [String] {
        guard let managedObjectContext = managedObjectContext else { return [] }

        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Light.fetchRequest()
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.propertiesToFetch = [ "title" ]
        fetchRequest.returnsDistinctResults = true
        fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "title", ascending: true) ]

        if let prefix = prefix, !prefix.isEmpty {
            fetchRequest.predicate = NSPredicate(format: "title BEGINSWITH %@", prefix)
        } else {
            fetchRequest.predicate = NSPredicate(format: "title != NULL AND title != ''")
        }

        let results = (try? managedObjectContext.performAndWait {
            return try fetchRequest.execute() as! [[String: String]]
            }) ?? []

        return results.compactMap { $0["title"] }
    }

}

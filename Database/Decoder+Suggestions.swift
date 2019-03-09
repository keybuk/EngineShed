//
//  Decoder+Suggestions.swift
//  EngineShed
//
//  Created by Scott James Remnant on 3/8/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation
import CoreData

extension Decoder {

    public func suggestionsForFirmwareVersion(startingWith prefix: String? = nil) -> [String] {
        guard let managedObjectContext = managedObjectContext else { return [] }

        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Decoder.fetchRequest()
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.propertiesToFetch = [ "firmwareVersion" ]
        fetchRequest.returnsDistinctResults = true
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "firmwareVersion", ascending: false)
        ]

        var predicates: [NSPredicate] = []
        if let productFamily = type?.productFamily, !productFamily.isEmpty {
            predicates.append(NSPredicate(format: "type.productFamily = %@", productFamily))
        } else if let type = type {
            predicates.append(NSPredicate(format: "type = %@", type))
        }

        if let prefix = prefix {
            predicates.append(NSPredicate(format: "firmwareVersion BEGINSWITH %@", prefix))
        }

        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)

        let results = (try? managedObjectContext.performAndWait {
            return try fetchRequest.execute() as! [[String: String]]
            }) ?? []

        return results.compactMap { $0["firmwareVersion"] }
    }

    public func suggestedFirmwareDate() -> NSDateComponents? {
        guard let managedObjectContext = managedObjectContext else { return nil }

        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Decoder.fetchRequest()
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.propertiesToFetch = [ "firmwareDate" ]
        fetchRequest.returnsDistinctResults = true

        var predicates: [NSPredicate] = []
        if let productFamily = type?.productFamily, !productFamily.isEmpty {
            predicates.append(NSPredicate(format: "type.productFamily = %@", productFamily))
        } else if let type = type {
            predicates.append(NSPredicate(format: "type = %@", type))
        }
        
        if let firmwareVersion = firmwareVersion, !firmwareVersion.isEmpty {
            predicates.append(NSPredicate(format: "firmwareVersion = %@", firmwareVersion))
        }

        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)

        let results = (try? managedObjectContext.performAndWait {
            return try fetchRequest.execute() as! [[String: NSDateComponents?]]
            }) ?? []

        return results.first?["firmwareDate"] ?? nil
    }

    public func suggestionsForSoundAuthor(startingWith prefix: String? = nil) -> [String] {
        guard let managedObjectContext = managedObjectContext else { return [] }

        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Decoder.fetchRequest()
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.propertiesToFetch = [ "soundAuthor" ]
        fetchRequest.returnsDistinctResults = true
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "soundAuthor", ascending: true)
        ]

        if let prefix = prefix {
            fetchRequest.predicate = NSPredicate(format: "soundAuthor BEGINSWITH %@", prefix)
        }

        let results = (try? managedObjectContext.performAndWait {
            return try fetchRequest.execute() as! [[String: String]]
            }) ?? []

        return results.compactMap { $0["soundAuthor"] }
    }

    public func suggestionsForSoundProject(startingWith prefix: String? = nil) -> [String] {
        guard let managedObjectContext = managedObjectContext else { return [] }

        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Decoder.fetchRequest()
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.propertiesToFetch = [ "soundProject" ]
        fetchRequest.returnsDistinctResults = true
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "soundProject", ascending: true)
        ]

        var predicates: [NSPredicate] = []

        if let soundAuthor = soundAuthor, !soundAuthor.isEmpty {
            predicates.append(NSPredicate(format: "soundAuthor = %@", soundAuthor))
        }

        if let prefix = prefix {
            predicates.append(NSPredicate(format: "soundProject BEGINSWITH %@", prefix))
        }

        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)

        let results = (try? managedObjectContext.performAndWait {
            return try fetchRequest.execute() as! [[String: String]]
            }) ?? []

        return results.compactMap { $0["soundProject"] }
    }

    public func suggestionsForSoundProjectVersion(startingWith prefix: String? = nil) -> [String] {
        guard let managedObjectContext = managedObjectContext else { return [] }

        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Decoder.fetchRequest()
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.propertiesToFetch = [ "soundProjectVersion" ]
        fetchRequest.returnsDistinctResults = true
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "soundProjectVersion", ascending: true)
        ]

        var predicates: [NSPredicate] = []

        if let soundProject = soundProject, !soundProject.isEmpty {
            predicates.append(NSPredicate(format: "soundProject = %@", soundProject))
        }

        if let prefix = prefix {
            fetchRequest.predicate = NSPredicate(format: "soundProjectVersion BEGINSWITH %@", prefix)
        }

        let results = (try? managedObjectContext.performAndWait {
            return try fetchRequest.execute() as! [[String: String]]
            }) ?? []

        return results.compactMap { $0["soundProjectVersion"] }
    }

}

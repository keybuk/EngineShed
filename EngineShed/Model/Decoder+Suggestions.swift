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

    func suggestionsForFirmwareVersion(startingWith prefix: String? = nil) -> [String] {
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

        if let prefix = prefix, !prefix.isEmpty {
            predicates.append(NSPredicate(format: "firmwareVersion BEGINSWITH %@", prefix))
        } else {
            predicates.append(NSPredicate(format: "firmwareVersion != NULL AND firmwareVersion != ''"))
        }

        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)

        let results = (try? managedObjectContext.performAndWait {
            return try fetchRequest.execute() as! [[String: String]]
            }) ?? []

        return results.compactMap { $0["firmwareVersion"] }
    }

    func suggestedFirmwareDate() -> DateComponents? {
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

        predicates.append(NSPredicate(format: "firmwareDate != NULL"))

        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)

        let results = (try? managedObjectContext.performAndWait {
            return try fetchRequest.execute() as! [[String: DateComponents?]]
            }) ?? []

        return results.first?["firmwareDate"] ?? nil
    }

    func suggestionsForSoundAuthor(startingWith prefix: String? = nil) -> [String] {
        guard let managedObjectContext = managedObjectContext else { return [] }

        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Decoder.fetchRequest()
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.propertiesToFetch = [ "soundAuthor" ]
        fetchRequest.returnsDistinctResults = true
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "soundAuthor", ascending: true)
        ]

        if let prefix = prefix, !prefix.isEmpty {
            fetchRequest.predicate = NSPredicate(format: "soundAuthor BEGINSWITH %@", prefix)
        } else {
            fetchRequest.predicate = NSPredicate(format: "soundAuthor != NULL AND soundAuthor != ''")
        }

        let results = (try? managedObjectContext.performAndWait {
            return try fetchRequest.execute() as! [[String: String]]
            }) ?? []

        return results.compactMap { $0["soundAuthor"] }
    }

    func suggestionsForSoundProject(startingWith prefix: String? = nil) -> [String] {
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

        if let prefix = prefix, !prefix.isEmpty {
            predicates.append(NSPredicate(format: "soundProject BEGINSWITH %@", prefix))
        } else {
            predicates.append(NSPredicate(format: "soundProject != NULL AND soundProject != ''"))
        }

        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)

        let results = (try? managedObjectContext.performAndWait {
            return try fetchRequest.execute() as! [[String: String]]
            }) ?? []

        return results.compactMap { $0["soundProject"] }
    }

    func suggestionsForSoundProjectVersion(startingWith prefix: String? = nil) -> [String] {
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

        if let prefix = prefix, !prefix.isEmpty {
            predicates.append(NSPredicate(format: "soundProjectVersion BEGINSWITH %@", prefix))
        } else {
            predicates.append(NSPredicate(format: "soundProjectVersion != NULL AND soundProjectVersion != ''"))
        }

        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)

        let results = (try? managedObjectContext.performAndWait {
            return try fetchRequest.execute() as! [[String: String]]
            }) ?? []

        return results.compactMap { $0["soundProjectVersion"] }
    }

}

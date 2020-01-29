//
//  Decoder.swift
//  TrainDatabase
//
//  Created by Scott James Remnant on 12/18/17.
//  Copyright © 2017 Scott James Remnant. All rights reserved.
//

import Foundation
import CoreData

import Database

extension Decoder {
    func delete() {
        managedObjectContext?.delete(self)
    }
    
    @discardableResult
    func deleteIfUnused() -> Bool {
        guard model == nil else { fatalError("deleteIfUnused should only be used on a decoder not in a model ")}

        // Discard any decoder without a type (since we can't reference it from the UI), or a typed decoder without other information.
        if type == nil || ((serialNumber?.isEmpty ?? true) && (firmwareVersion?.isEmpty ?? true) && firmwareDate == nil && address == 0 && (soundAuthor?.isEmpty ?? true) && (soundProject?.isEmpty ?? true)) {
            managedObjectContext?.delete(self)
            return true
        }
        
        return false
    }
    
    @discardableResult
    func deleteIfEmpty() -> Bool {
        guard model != nil else { fatalError("deleteIfEmpty should only be used on a model's decoder" )}

        // This is subtly different from above - this only discard a decoder if it contains no information aside from being attached to a model, while
        // the above is intended for use when a decoder is no longer attached to a model.
        if type == nil && (serialNumber?.isEmpty ?? true) && (firmwareVersion?.isEmpty ?? true) && firmwareDate == nil && address == 0 && (soundAuthor?.isEmpty ?? true) && (soundProject?.isEmpty ?? true) {
            managedObjectContext?.delete(self)
            return true
        }
        
        return false
    }

    func sortedValuesForFirmwareVersion(startingWith string: String? = nil) throws -> [String] {
        guard let context = managedObjectContext else { fatalError("No context to make query with") }
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Decoder.fetchRequest()
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.returnsDistinctResults = true
        fetchRequest.propertiesToFetch = [ "firmwareVersion" ]
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "firmwareVersion", ascending: false)
        ]
        
        var predicates: [NSPredicate] = []
        predicates.append(NSPredicate(format: "firmwareVersion != ''"))
        
        if let string = string {
            predicates.append(NSPredicate(format: "firmwareVersion BEGINSWITH[c] %@", string))
        }
    
        if let decoderType = type {
            if let productFamily = decoderType.productFamily, !productFamily.isEmpty {
                predicates.append(NSPredicate(format: "type.productFamily = %@", productFamily))
            } else {
                predicates.append(NSPredicate(format: "type = %@", decoderType))
            }
        }
        
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        let results = try context.fetch(fetchRequest) as! [[String: String]]
        return results.map({ $0["firmwareVersion"]! })
    }

    func sortedValuesForSoundAuthor(startingWith string: String? = nil) throws -> [String] {
        return try sortedValues(for: "soundAuthor", ascending: true, startingWith: string)
    }

    func suggestedFirmwareDate(for version: String) throws -> DateComponents? {
        guard let context = managedObjectContext else { fatalError("No context to make query with") }
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Decoder.fetchRequest()
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.returnsDistinctResults = true
        fetchRequest.propertiesToFetch = [ "firmwareDate" ]
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "firmwareDate", ascending: false)
        ]
        
        var predicates: [NSPredicate] = []
        predicates.append(NSPredicate(format: "firmwareVersion = %@", version))
        
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        let results = try context.fetch(fetchRequest) as! [[String: DateComponents?]]
        return results.first.flatMap({ $0["firmwareDate"] ?? nil })
    }
}

extension Decoder/* : CustomStringConvertible*/ {
    override public var description: String {
        return serialNumber ?? ""
    }
}

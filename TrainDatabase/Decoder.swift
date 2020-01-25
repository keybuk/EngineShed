//
//  Decoder.swift
//  TrainDatabase
//
//  Created by Scott James Remnant on 12/18/17.
//  Copyright © 2017 Scott James Remnant. All rights reserved.
//

import Foundation
import CoreData

struct Decoder : ManagedObjectBacked {

    var managedObject: DecoderManagedObject
    
    init(managedObject: DecoderManagedObject) {
        self.managedObject = managedObject
    }
    
    init(context: NSManagedObjectContext) {
        managedObject = DecoderManagedObject(context: context)
        managedObject.serialNumber = ""
        managedObject.firmwareVersion = ""
        managedObject.soundAuthor = ""
        managedObject.soundProject = ""
    }


    var type: DecoderType? {
        get { return managedObject.type.map(DecoderType.init(managedObject:)) }
        set {
            managedObject.type = newValue?.managedObject
            try? managedObject.managedObjectContext?.save()
        }
    }
    
    var model: Model? {
        get { return managedObject.model.map(Model.init(managedObject:)) }
        set {
            managedObject.model = newValue?.managedObject
            try? managedObject.managedObjectContext?.save()
        }
    }
    
    
    var serialNumber: String {
        get { return managedObject.serialNumber ?? "" }
        set {
            managedObject.serialNumber = newValue
            try? managedObject.managedObjectContext?.save()
        }
    }
    
    var firmwareVersion: String {
        get { return managedObject.firmwareVersion ?? "" }
        set {
            managedObject.firmwareVersion = newValue
            try? managedObject.managedObjectContext?.save()
        }
    }
    
    var firmwareDate: Date? {
        get { return managedObject.firmwareDate }
        set {
            managedObject.firmwareDate = newValue
            try? managedObject.managedObjectContext?.save()
        }
    }
    
    var address: Int {
        get { return Int(managedObject.address) }
        set {
            managedObject.address = Int16(newValue)
            try? managedObject.managedObjectContext?.save()
        }
    }
    
    var soundAuthor: String {
        get { return managedObject.soundAuthor ?? "" }
        set {
            managedObject.soundAuthor = newValue
            try? managedObject.managedObjectContext?.save()
        }
    }
    
    var soundProject: String {
        get { return managedObject.soundProject ?? "" }
        set {
            managedObject.soundProject = newValue
            try? managedObject.managedObjectContext?.save()
        }
    }
    
    
    func delete() {
        managedObject.managedObjectContext?.delete(managedObject)
        try? managedObject.managedObjectContext?.save()
    }
    
    @discardableResult
    func deleteIfUnused() -> Bool {
        guard model == nil else { fatalError("deleteIfUnused should only be used on a decoder not in a model ")}

        // Discard any decoder without a type (since we can't reference it from the UI), or a typed decoder without other information.
        if type == nil || (serialNumber.isEmpty && firmwareVersion.isEmpty && firmwareDate == nil && address == 0 && soundAuthor.isEmpty && soundProject.isEmpty) {
            managedObject.managedObjectContext?.delete(managedObject)
            try? managedObject.managedObjectContext?.save()
            return true
        }
        
        return false
    }
    
    @discardableResult
    func deleteIfEmpty() -> Bool {
        guard model != nil else { fatalError("deleteIfEmpty should only be used on a model's decoder" )}

        // This is subtly different from above - this only discard a decoder if it contains no information aside from being attached to a model, while
        // the above is intended for use when a decoder is no longer attached to a model.
        if type == nil && serialNumber.isEmpty && firmwareVersion.isEmpty && firmwareDate == nil && address == 0 && soundAuthor.isEmpty && soundProject.isEmpty {
            managedObject.managedObjectContext?.delete(managedObject)
            try? managedObject.managedObjectContext?.save()
            return true
        }
        
        return false
    }

    
    
    func sortedValuesForFirmwareVersion(startingWith string: String? = nil) throws -> [String] {
        guard let context = managedObject.managedObjectContext else { fatalError("No context to make query with") }
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = DecoderManagedObject.fetchRequest()
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
            if !decoderType.productFamily.isEmpty {
                predicates.append(NSPredicate(format: "type.productFamily = %@", decoderType.productFamily))
            } else {
                predicates.append(NSPredicate(format: "type = %@", decoderType.managedObject))
            }
        }
        
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        let results = try context.fetch(fetchRequest) as! [[String: String]]
        return results.map({ $0["firmwareVersion"]! })
    }

    func sortedValuesForSoundAuthor(startingWith string: String? = nil) throws -> [String] {
        return try sortedValues(for: "soundAuthor", ascending: true, startingWith: string)
    }


    func firmwareDate(for version: String) throws -> Date? {
        guard let context = managedObject.managedObjectContext else { fatalError("No context to make query with") }
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = DecoderManagedObject.fetchRequest()
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.returnsDistinctResults = true
        fetchRequest.propertiesToFetch = [ "firmwareDate" ]
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "firmwareDate", ascending: false)
        ]
        
        var predicates: [NSPredicate] = []
        predicates.append(NSPredicate(format: "firmwareVersion = %@", version))
        
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        let results = try context.fetch(fetchRequest) as! [[String: Date?]]
        return results.first.flatMap({ $0["firmwareDate"] ?? nil })
    }
    
}

extension Decoder : CustomStringConvertible {
    
    var description: String {
        return serialNumber
    }
    
}


extension Decoder : Encodable {

    enum CodingKeys : String, CodingKey {
        case id
        case serialNumber
        case firmwareVersion
        case firmwareDate
        case address
        case soundAuthor
        case soundProject
        case modelID
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(managedObject.objectID.uriRepresentation(), forKey: .id)
        try container.encode(serialNumber, forKey: .serialNumber)
        try container.encode(firmwareVersion, forKey: .firmwareVersion)
        try container.encodeIfPresent(firmwareDate, forKey: .firmwareDate)
        try container.encode(address, forKey: .address)
        try container.encode(soundAuthor, forKey: .soundAuthor)
        try container.encode(soundProject, forKey: .soundProject)
        try container.encodeIfPresent(model?.managedObject.objectID.uriRepresentation(), forKey: .modelID)
    }
    
}

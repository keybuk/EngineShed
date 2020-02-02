//
//  DecoderType.swift
//  TrainDatabase
//
//  Created by Scott James Remnant on 12/16/17.
//  Copyright © 2017 Scott James Remnant. All rights reserved.
//

import Foundation
import CoreData

import Database

extension DecoderType {
    func addDecoder() -> Decoder {
        let decoder = Decoder(context: managedObjectContext!)
        decoder.type = self
        return decoder
    }

    func sortedValuesForManufacturer(startingWith string: String? = nil) throws -> [String] {
        return try sortedValues(for: "manufacturer", ascending: true, startingWith: string)
    }

    func sortedValuesForProductFamily(startingWith string: String? = nil) throws -> [String] {
        guard let managedObjectContext = managedObjectContext else { fatalError("No context to make query with") }
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = DecoderType.fetchRequest()
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.returnsDistinctResults = true
        fetchRequest.propertiesToFetch = [ "productFamily" ]
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "productFamily", ascending: true),
        ]
        
        var predicates: [NSPredicate] = []
        predicates.append(NSPredicate(format: "productFamily != ''"))
        
        if let manufacturer = manufacturer, !manufacturer.isEmpty {
            predicates.append(NSPredicate(format: "manufacturer = %@", manufacturer))
        }
        
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        let results = try managedObjectContext.fetch(fetchRequest) as! [[String: String]]
        return results.map({ $0["productFamily"]! })
    }

    func sortedValuesForSocket(startingWith string: String? = nil) throws -> [String] {
        return try sortedValues(for: "socket", ascending: true, startingWith: string)
    }
    
    // FIXME: this means decoders with no model, not unallocated in the newer sense.
    func unallocatedDecoders() -> [Decoder] {
        let fetchRequest = fetchRequestForDecoders()

        let results = try! managedObjectContext!.fetch(fetchRequest)
        return results
    }
    
    static func all(in context: NSManagedObjectContext) throws -> [DecoderType] {
        let fetchRequest: NSFetchRequest<DecoderType> = DecoderType.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "manufacturer", ascending: true),
            NSSortDescriptor(key: "productCode", ascending: true)
        ]
        
        let results = try context.fetch(fetchRequest)
        return results
    }
}

extension DecoderType/* : CustomStringConvertible*/ {
    override public var description: String {
        let description = [ manufacturer, productCode, productFamily ].compactMap({ $0 }).filter({ !$0.isEmpty }).joined(separator: " ")
        return (socket?.isEmpty ?? true) ? description : description + " (\(socket!))"
    }
}

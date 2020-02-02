//
//  DecoderType+FetchRequests.swift
//  Database
//
//  Created by Scott James Remnant on 2/1/20.
//  Copyright © 2020 Scott James Remnant. All rights reserved.
//

import Foundation
import CoreData

extension DecoderType {
    /// Returns an `NSFetchRequest` for all decoders of this type.
    /// - Parameter includingFitted: `true` if decoders fitted to models should be included, default: `false`.
    /// - Parameter includingAllocated: `true` if decoders allocated to sound projects should be included, default `true`.
    public func fetchRequestForDecoders(includingFitted: Bool = false,
                                        includingAllocated: Bool = true) -> NSFetchRequest<Decoder> {
        let fetchRequest: NSFetchRequest<Decoder> = Decoder.fetchRequest()

        var predicates: [NSPredicate] = []
        predicates.append(NSPredicate(format: "type = %@", self))
        if !includingFitted {
            predicates.append(NSPredicate(format: "model = nil"))
        }
        if !includingAllocated {
            predicates.append(NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "soundAuthor = nil OR soundAuthor = ''"),
                NSPredicate(format: "soundProject = nil OR soundProject = ''"),
                NSPredicate(format: "soundProjectVersion = nil OR soundProjectVersion = ''"),
                NSPredicate(format: "soundSettings = nil OR soundSettings = ''")
            ]))
        }
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)

        var sortDescriptors: [NSSortDescriptor] = []
        sortDescriptors.append(NSSortDescriptor(key: "serialNumber", ascending: true))
        fetchRequest.sortDescriptors = sortDescriptors

        return fetchRequest
    }
}

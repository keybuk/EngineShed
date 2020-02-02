//
//  Model+FetchRequests.swift
//  EngineShed
//
//  Created by Scott James Remnant on 2/1/20.
//  Copyright © 2020 Scott James Remnant. All rights reserved.
//

import Foundation
import CoreData

extension Model {
    /// Sort criteria for models.
    public enum Sort {
        /// Sort by the model's class.
        case modelClass
        /// Sort by the model's era.
        case era
        /// Sort by the model's livery.
        case livery
    }

    /// Fields that we perform text searches against.
    static let searchFields = [ "modelClass", "number", "name", "purchase.catalogNumber", "purchase.catalogDescription", "decoder.serialNumber" ]

    /// Returns an `NSFetchRequest` for all models.
    /// - Parameter classification: classification of models to include, defaults to all classifications.
    /// - Parameter search: text to match models against, defaults to all models.
    public static func fetchRequestForModels(classification: Classification? = nil,
                                             matching search: String? = nil,
                                             sortedBy sort: Sort = .modelClass) -> NSFetchRequest<Model> {
        let fetchRequest: NSFetchRequest<Model> = Model.fetchRequest()

        var predicates: [NSPredicate] = []
        if let classification = classification {
            predicates.append(NSPredicate(format: "classificationRawValue = \(classification.rawValue)"))
        }
        if let search = search {
            predicates.append(NSCompoundPredicate(orPredicateWithSubpredicates: searchFields.map {
                NSPredicate(format: "\($0) CONTAINS[c] %@", search)
            }))
        }
        if !predicates.isEmpty {
            fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        
        var sortDescriptors: [NSSortDescriptor] = []
        switch sort {
        case .modelClass: break
        case .era:
            sortDescriptors.append(NSSortDescriptor(key: "eraRawValue", ascending: true))
        case .livery:
            sortDescriptors.append(NSSortDescriptor(key: "livery", ascending: true))
        }
        sortDescriptors.append(contentsOf: [
            NSSortDescriptor(key: "modelClass", ascending: true),
            NSSortDescriptor(key: "number", ascending: true),
            NSSortDescriptor(key: "name", ascending: true),
            NSSortDescriptor(key: "dispositionRawValue", ascending: true),
        ])
        fetchRequest.sortDescriptors = sortDescriptors

        return fetchRequest
    }
}

//
//  Model+FetchRequests.swift
//  EngineShed
//
//  Created by Scott James Remnant on 7/30/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import Foundation
import CoreData

enum ModelGrouping {

    case modelClass
    case era
    case livery

}

extension Model {

    static func fetchRequestForModels(classification: Classification? = nil, groupBy grouping: ModelGrouping = .modelClass) -> NSFetchRequest<Model> {
        let fetchRequest: NSFetchRequest<Model> = Model.fetchRequest()
        fetchRequest.fetchBatchSize = 20

        if let classification = classification {
            fetchRequest.predicate = NSPredicate(format: "classificationRawValue = %d", classification.rawValue)
        }


        var sortDescriptors: [NSSortDescriptor] = []

        switch grouping {
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
            NSSortDescriptor(key: "dispositionRawValue", ascending: true)
        ])

        fetchRequest.sortDescriptors = sortDescriptors

        return fetchRequest
    }
    
}


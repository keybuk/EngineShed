//
//  Model+FetchRequests.swift
//  EngineShed
//
//  Created by Scott James Remnant on 7/30/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import CoreData

extension Model {

    public static func fetchRequestForModels(context: NSManagedObjectContext) -> NSFetchRequest<Model> {
        let fetchRequest: NSFetchRequest<Model> = Model.fetchRequest()
        fetchRequest.fetchBatchSize = 20
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "modelClass", ascending: true),
            NSSortDescriptor(key: "number", ascending: true),
            NSSortDescriptor(key: "name", ascending: true),
            NSSortDescriptor(key: "dispositionRawValue", ascending: true)
        ]

        return fetchRequest
    }
    
}


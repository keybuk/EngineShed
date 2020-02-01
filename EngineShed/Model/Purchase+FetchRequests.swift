//
//  Purchase+FetchRequests.swift
//  EngineShed
//
//  Created by Scott James Remnant on 1/12/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation
import CoreData

import Database

extension Purchase {
    func fetchRequestForModels() -> NSFetchRequest<Model> {
        let fetchRequest: NSFetchRequest<Model> = Model.fetchRequest()

        fetchRequest.predicate = NSPredicate(format: "purchase = %@", self)

        var sortDescriptors: [NSSortDescriptor] = []
        sortDescriptors.append(NSSortDescriptor(key: "index", ascending: true))

        fetchRequest.sortDescriptors = sortDescriptors

        return fetchRequest
    }
}

//
//  Purchase+FetchRequests.swift
//  EngineShed
//
//  Created by Scott James Remnant on 1/12/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation
import CoreData

extension Purchase {
    enum Ordering {
        case date
        case catalog
    }

    static func fetchRequestForPurchases(orderingBy ordering: Ordering = .catalog) -> NSFetchRequest<Purchase> {
        let fetchRequest: NSFetchRequest<Purchase> = Purchase.fetchRequest()
        fetchRequest.fetchBatchSize = 20

        var sortDescriptors: [NSSortDescriptor] = []

        switch ordering {
        case .date:
            sortDescriptors.append(NSSortDescriptor(key: "dateForGrouping", ascending: false))
            sortDescriptors.append(NSSortDescriptor(key: "dateForSort", ascending: false))
            sortDescriptors.append(NSSortDescriptor(key: "store", ascending: true))
            sortDescriptors.append(NSSortDescriptor(key: "manufacturer", ascending: true))
            sortDescriptors.append(NSSortDescriptor(key: "catalogNumber", ascending: true))
        case .catalog:
            sortDescriptors.append(NSSortDescriptor(key: "manufacturer", ascending: true))
            sortDescriptors.append(NSSortDescriptor(key: "catalogNumber", ascending: true))
            sortDescriptors.append(NSSortDescriptor(key: "dateForSort", ascending: true))
            sortDescriptors.append(NSSortDescriptor(key: "store", ascending: true))
        }

        fetchRequest.sortDescriptors = sortDescriptors

        return fetchRequest
    }

    func fetchRequestForModels() -> NSFetchRequest<Model> {
        let fetchRequest: NSFetchRequest<Model> = Model.fetchRequest()
        fetchRequest.fetchBatchSize = 20

        fetchRequest.predicate = NSPredicate(format: "purchase = %@", self)

        var sortDescriptors: [NSSortDescriptor] = []
        sortDescriptors.append(NSSortDescriptor(key: "index", ascending: true))

        fetchRequest.sortDescriptors = sortDescriptors

        return fetchRequest
    }
}

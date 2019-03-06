//
//  Purchase+FetchRequests.swift
//  EngineShed
//
//  Created by Scott James Remnant on 1/12/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation
import CoreData

public enum PurchaseOrdering {

    case catalog
    case date

}

extension Purchase {

    public static func fetchRequestForPurchases(orderingBy ordering: PurchaseOrdering = .catalog) -> NSFetchRequest<Purchase> {
        let fetchRequest: NSFetchRequest<Purchase> = Purchase.fetchRequest()
        fetchRequest.fetchBatchSize = 20

        var sortDescriptors: [NSSortDescriptor] = []

        switch ordering {
        case .catalog:
            sortDescriptors.append(NSSortDescriptor(key: "manufacturer", ascending: true))
            sortDescriptors.append(NSSortDescriptor(key: "catalogNumber", ascending: true))
            sortDescriptors.append(NSSortDescriptor(key: "dateForSort", ascending: true))
            sortDescriptors.append(NSSortDescriptor(key: "store", ascending: true))
        case .date:
            sortDescriptors.append(NSSortDescriptor(key: "dateForGrouping", ascending: false))
            sortDescriptors.append(NSSortDescriptor(key: "dateForSort", ascending: false))
            sortDescriptors.append(NSSortDescriptor(key: "store", ascending: true))
            sortDescriptors.append(NSSortDescriptor(key: "manufacturer", ascending: true))
            sortDescriptors.append(NSSortDescriptor(key: "catalogNumber", ascending: true))
        }

        fetchRequest.sortDescriptors = sortDescriptors

        return fetchRequest
    }

}


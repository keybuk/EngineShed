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
    /// Sort criteria for purchases.
    public enum Sort {
        /// Sort by purchase date.
        case date
        /// Sort by manufacturer and catalog number.
        case catalog
    }

    /// Returns an `NSFetchRequest` for all purchases.
    /// - Parameter sort: sort criteria, default `.catalog`
    public static func fetchRequestForPurchases(sortedBy sort: Sort = .catalog) -> NSFetchRequest<Purchase> {
        let fetchRequest: NSFetchRequest<Purchase> = Purchase.fetchRequest()

        var sortDescriptors: [NSSortDescriptor] = []
        switch sort {
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
}

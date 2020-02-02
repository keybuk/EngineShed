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
            sortDescriptors.append(contentsOf: [
                NSSortDescriptor(key: "dateForGrouping", ascending: false),
                NSSortDescriptor(key: "dateForSort", ascending: false),
                NSSortDescriptor(key: "store", ascending: true),
                NSSortDescriptor(key: "manufacturer", ascending: true),
                NSSortDescriptor(key: "catalogNumber", ascending: true),
            ])
        case .catalog:
            sortDescriptors.append(contentsOf: [
                NSSortDescriptor(key: "manufacturer", ascending: true),
                NSSortDescriptor(key: "catalogNumber", ascending: true),
                NSSortDescriptor(key: "dateForSort", ascending: true),
                NSSortDescriptor(key: "store", ascending: true),
            ])
        }
        fetchRequest.sortDescriptors = sortDescriptors

        return fetchRequest
    }
}

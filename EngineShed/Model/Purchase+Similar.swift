//
//  Purchase+Similar.swift
//  EngineShed
//
//  Created by Scott James Remnant on 6/22/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import Foundation
import CoreData

import Database

extension Purchase {
    /// Update the catalogNumberPrefix field.
    func updateCatalogNumberPrefix() {
        // Update the `catalogNumberPrefix` field on save from `catalogNumber`.
        if let catalogNumber = catalogNumber {
            let catalogNumberPrefix = makeCatalogNumberPrefix(from: catalogNumber)
            if self.catalogNumberPrefix != catalogNumberPrefix {
                self.catalogNumberPrefix = catalogNumberPrefix
            }
        } else if catalogNumberPrefix != nil {
            catalogNumberPrefix = nil
        }
    }

    /// Return list of similar purchases.
    ///
    /// Similar purchases are those where the `catalogNumber` matches, or if no exact match, where
    /// the `catalogNumberPrefix` matches. Where there are exact matches, only those will be
    /// returned.
    ///
    /// In either case, `manufacturer` must match.
    ///
    /// - Returns: list of matching `Purchase` objects, or empty list if none.
    func similar() -> [Purchase] {
        guard let manufacturer = manufacturer, manufacturer != "" else { return [] }
        guard let catalogNumber = catalogNumber, catalogNumber != "" else { return [] }

        // Generate a new copy of the catalog number prefix, rather than using the one in the
        // object, because that one is intended for this method to search against, not
        // search with, and thus is only updated on save.
        let catalogNumberPrefix = makeCatalogNumberPrefix(from: catalogNumber)
        guard catalogNumberPrefix != "" else { return [] }

        let fetchRequest: NSFetchRequest<Purchase> = Purchase.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "SELF != %@ && manufacturer = %@ && catalogNumberPrefix = %@", self, manufacturer, catalogNumberPrefix)

        let purchases = (try? managedObjectContext?.performAndWait {
            return try fetchRequest.execute()
        }) ?? []

        let exactMatches = purchases.filter { $0.catalogNumber == catalogNumber }
        if !exactMatches.isEmpty {
            return exactMatches
        } else {
            return purchases
        }
    }

}

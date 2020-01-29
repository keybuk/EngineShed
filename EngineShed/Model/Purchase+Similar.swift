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

    /// Returns the common catalog number prefix for a catalog number.
    ///
    /// Most model railway manufacturers use a system where common models differing only in running
    /// numbers, or sometimes liveries, share a common catalog number prefix. For Hornby and
    /// Bachmann for example, *R1000*, *R1000A*, and *R1000B* are all variations of the same
    /// original model.
    ///
    /// - Parameter catalogNumber: full catalog number.
    /// - Returns: `catalogNumber` or the common prefix equivalent, which is always shorter.
    func makePrefix(from catalogNumber: String) -> String {
        let parts = catalogNumber.split(between: {
            if $0.isWhitespace && $1.isWhitespace { return false }
            if $0.isLetter && $1.isLetter { return false }
            if $0.isNumber && $1.isNumber { return false }
            if $0.isPunctuation && $1.isPunctuation { return false }
            return true
        })

        if let lastDash = parts.lastIndex(of: "-") {
            if lastDash != parts.firstIndex(of: "-") {
                // Dapol, Hattons, etc. with more than one dash, remove everything past the last dash.
                return parts[...lastDash].joined()
            } else if parts.count > 0 && parts[0].count > 2 && parts[0].first!.isNumber {
                // Special case for Realtrack, the first part is a number sequence longer than two.
                return parts[...lastDash].joined()
            }
        }

        // Hornby, Bachmann, final-letter style.
        if parts.count > 1 && parts.last!.first!.isLetter {
            return parts.dropLast().joined()
        }

        // Oxford Diecast style; number, letter, long number. Shrink long number to three digits.
        if parts.count == 3 && parts[0].first!.isNumber && parts[1].first!.isLetter && parts[2].first!.isNumber && parts[2].count > 3 {
            return (parts[..<2] + parts[2...].map { $0.prefix(3) }).joined()
        }

        return parts.joined()
    }

    /// Update the catalogNumberPrefix field.
    func updateCatalogNumberPrefix() {
        // Update the `catalogNumberPrefix` field on save from `catalogNumber`.
        if let catalogNumber = catalogNumber {
            let catalogNumberPrefix = makePrefix(from: catalogNumber)
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
        let catalogNumberPrefix = makePrefix(from: catalogNumber)
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

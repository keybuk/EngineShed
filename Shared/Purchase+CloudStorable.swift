//
//  Purchase+CloudStorable.swift
//  EngineShed
//
//  Created by Scott James Remnant on 6/17/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import CloudKit
import CoreData

extension Purchase : CloudStorable {

    /// CloudKit record type.
    static let recordType = "Purchase"

    internal func update(from record: CKRecord) throws {
        catalogDescription = record["catalogDescription"]
        catalogNumber = record["catalogNumber"]
        catalogYear = record["catalogYear"] ?? 0
        conditionRawValue = record["condition"] ?? 0
        date = record["date"]
        limitedEdition = record["limitedEdition"]
        limitedEditionCount = record["limitedEditionCount"] ?? 0
        limitedEditionNumber = record["limitedEditionNumber"] ?? 0
        manufacturer = record["manufacturer"]
        notes = record["notes"]
        store = record["store"]

        if let number = record["price"] as? NSNumber {
            price = NSDecimalNumber(decimal: number.decimalValue)
        } else {
            price = nil
        }

        if let number = record["valuation"] as? NSNumber {
            valuation = NSDecimalNumber(decimal: number.decimalValue)
        } else {
            valuation = nil
        }
    }

}

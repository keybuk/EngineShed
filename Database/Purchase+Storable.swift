//
//  Purchase+Storable.swift
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

    /// Update the managed object from a CloudKit record.
    ///
    /// - Parameters:
    ///   - record: CloudKit record to update from.
    func update(from record: CKRecord) throws {
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

        if let data = record["price"] as? Data,
            let unarchiver = try? NSKeyedUnarchiver(forReadingFrom: data)
        {
            price = unarchiver.decodeObject(of: NSDecimalNumber.self, forKey: "Price")
            unarchiver.finishDecoding()
        } else {
            price = nil
        }

        if let data = record["valuation"] as? Data,
            let unarchiver = try? NSKeyedUnarchiver(forReadingFrom: data)
        {
            valuation = unarchiver.decodeObject(of: NSDecimalNumber.self, forKey: "Valuation")
            unarchiver.finishDecoding()
        } else {
            valuation = nil
        }

        // TODO: this doesn't feel like the optimal approach for this
        if let references = record["models"] as? [CKRecord.Reference] {
            models.map { removeFromModels($0) }
            for reference in try references.map { try Model.objectForRecordID($0.recordID, in: managedObjectContext!) } {
                addToModels(reference)
            }
        } else {
            models = nil
        }
    }

    /// Update a CloudKit record from this managed object.
    ///
    /// - Parameters:
    ///   - record: CloudKit record to update.
    ///   - keys: update only these keys (managed object name), or all keys if `nil.
    func updateRecord(_ record: CKRecord, forKeys keys: Set<String>?) {
        if keys?.contains("catalogDescription") ?? true { record["catalogDescription"] = catalogDescription }
        if keys?.contains("catalogNumber") ?? true { record["catalogNumber"] = catalogNumber }
        if keys?.contains("catalogYear") ?? true { record["catalogYear"] = catalogYear }
        if keys?.contains("conditionRawValue") ?? true { record["condition"] = conditionRawValue }
        if keys?.contains("date") ?? true { record["date"] = date }
        if keys?.contains("limitedEdition") ?? true { record["limitedEdition"] = limitedEdition }
        if keys?.contains("limitedEditionCount") ?? true { record["limitedEditionCount"] = limitedEditionCount }
        if keys?.contains("limitedEditionNumber") ?? true { record["limitedEditionNumber"] = limitedEditionNumber }
        if keys?.contains("manufacturer") ?? true { record["manufacturer"] = manufacturer }
        if keys?.contains("notes") ?? true { record["notes"] = notes }
        if keys?.contains("store") ?? true { record["store"] = store }

        if keys?.contains("price") ?? true {
            record["price"] = price.map {
                let archiver = NSKeyedArchiver(requiringSecureCoding: true)
                archiver.encode($0, forKey: "Price")
                archiver.finishEncoding()
                return archiver.encodedData as NSData
            }
        }
        if keys?.contains("valuation") ?? true {
            record["valuation"] = valuation.map {
                let archiver = NSKeyedArchiver(requiringSecureCoding: true)
                archiver.encode($0, forKey: "Valuation")
                archiver.finishEncoding()
                return archiver.encodedData as NSData
            }
        }

        if keys?.contains("models") ?? true {
            if let models = models?.array as? [Model] {
                record["models"] = models.compactMap { $0.recordID.map { CKRecord.Reference(recordID: $0, action: .none) } }
            } else {
                record["models"] = nil
            }
        }
    }

}

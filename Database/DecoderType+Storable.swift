//
//  DecoderType+Storable.swift
//  EngineShed
//
//  Created by Scott James Remnant on 6/17/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import CloudKit
import CoreData

extension DecoderType : CloudStorable {

    /// CloudKit record type.
    static let recordType = "DecoderType"

    /// Update the managed object from a CloudKit record.
    ///
    /// - Parameters:
    ///   - record: CloudKit record to update from.
    func update(from record: CKRecord) throws {
        hasRailCom = record["hasRailCom"] ?? false
        hasSound = record["hasSound"] ?? false
        isProgrammable = record["isProgrammable"] ?? false
        manufacturer = record["manufacturer"]
        minimumStock = record["minimumStock"] ?? 0
        productCode = record["productCode"]
        productDescription = record["productDescription"]
        productFamily = record["productFamily"]
        socket = record["socket"]
    }

    /// Update a CloudKit record from this managed object.
    ///
    /// - Parameters:
    ///   - record: CloudKit record to update.
    ///   - keys: update only these keys (managed object name), or all keys if `nil.
    func updateRecord(_ record: CKRecord, forKeys keys: Set<String>?) {
        if keys?.contains("hasRailCom") ?? true { record["hasRailCom"] = hasRailCom }
        if keys?.contains("hasSound") ?? true { record["hasSound"] = hasSound }
        if keys?.contains("isProgrammable") ?? true { record["isProgrammable"] = isProgrammable }
        if keys?.contains("manufacturer") ?? true { record["manufacturer"] = manufacturer }
        if keys?.contains("minimumStock") ?? true { record["minimumStock"] = minimumStock }
        if keys?.contains("productCode") ?? true { record["productCode"] = productCode }
        if keys?.contains("productDescription") ?? true { record["productDescription"] = productDescription }
        if keys?.contains("productFamily") ?? true { record["productFamily"] = productFamily }
        if keys?.contains("socket") ?? true { record["socket"] = socket }
    }

}

//
//  Decoder+Storable.swift
//  EngineShed
//
//  Created by Scott James Remnant on 6/17/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import CloudKit
import CoreData

extension Decoder : StorableManagedObject {

    /// CloudKit record type.
    static let recordType = "Decoder"

    /// Update the managed object from a CloudKit record.
    ///
    /// - Parameters:
    ///   - record: CloudKit record to update from.
    internal func update(from record: CKRecord) throws {
        address = record["address"] ?? 0
        firmwareDate = record["firmwareDate"]
        firmwareVersion = record["firmwareVersion"]
        serialNumber = record["serialNumber"]
        soundAuthor = record["soundAuthor"]
        soundFile = record["soundFile"]

        if let reference = record["model"] as? CKRecord.Reference {
            model = try Model.objectForRecordID(reference.recordID, in: managedObjectContext!)
        } else {
            model = nil
        }

        if let reference = record["type"] as? CKRecord.Reference {
            type = try DecoderType.objectForRecordID(reference.recordID, in: managedObjectContext!)
        } else {
            type = nil
        }
    }

    /// Update a CloudKit record from this managed object.
    ///
    /// - Parameters:
    ///   - record: CloudKit record to update.
    ///   - keys: update only these keys (managed object name), or all keys if `nil.
    internal func updateRecord(_ record: CKRecord, forKeys keys: Set<String>?) {
        if keys?.contains("address") ?? true { record["address"] = address }
        if keys?.contains("firmwareDate") ?? true { record["firmwareDate"] = firmwareDate }
        if keys?.contains("firmwareVersion") ?? true { record["firmwareVersion"] = firmwareVersion }
        if keys?.contains("serialNumber") ?? true { record["serialNumber"] = serialNumber }
        if keys?.contains("soundAuthor") ?? true { record["soundAuthor"] = soundAuthor }
        if keys?.contains("soundFile") ?? true { record["soundFile"] = soundFile }

        if keys?.contains("model") ?? true {
            if let recordID = model?.recordID {
                record["model"] = CKRecord.Reference(recordID: recordID, action: .none)
            } else {
                record["model"] = nil
            }
        }

        if keys?.contains("type") ?? true {
            if let recordID = type?.recordID {
                record["type"] = CKRecord.Reference(recordID: recordID, action: .deleteSelf)
            } else {
                record["type"] = nil
            }
        }
    }

}

//
//  TrainMember+CloudStorable.swift
//  EngineShed
//
//  Created by Scott James Remnant on 6/17/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import CloudKit
import CoreData

extension TrainMember : CloudStorable {

    /// CloudKit record type.
    static let recordType = "TrainMember"

    /// Update the managed object from a CloudKit record.
    ///
    /// - Parameters:
    ///   - record: CloudKit record to update from.
    internal func update(from record: CKRecord) throws {
        isFlipped = record["isFlipped"] ?? false
        title = record["title"]

        if let reference = record["model"] as? CKRecord.Reference {
            model = try Model.forRecordID(reference.recordID, in: managedObjectContext!)
        } else {
            model = nil
        }

        if let reference = record["train"] as? CKRecord.Reference {
            train = try Train.forRecordID(reference.recordID, in: managedObjectContext!)
        } else {
            train = nil
        }
    }

    /// Update a CloudKit record from this managed object.
    ///
    /// - Parameters:
    ///   - record: CloudKit record to update.
    ///   - keys: update only these keys (managed object name), or all keys if `nil.
    internal func updateRecord(_ record: CKRecord, forKeys keys: Set<String>?) {
        if keys?.contains("isFlipped") ?? true { record["isFlipped"] = isFlipped }
        if keys?.contains("title") ?? true { record["title"] = title }

        if keys?.contains("model") ?? true {
            if let modelRecord = model?.record {
                record["model"] = CKRecord.Reference(record: modelRecord, action: .none)
            } else {
                record["model"] = nil
            }
        }

        if keys?.contains("train") ?? true {
            if let trainRecord = train?.record {
                record["train"] = CKRecord.Reference(record: trainRecord, action: .deleteSelf)
            } else {
                record["train"] = nil
            }
        }
    }

}

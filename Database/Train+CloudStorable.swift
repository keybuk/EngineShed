//
//  Train+CloudStorable.swift
//  EngineShed
//
//  Created by Scott James Remnant on 6/17/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import CloudKit
import CoreData

extension Train : CloudStorable {

    /// CloudKit record type.
    static let recordType = "Train"

    /// Update the managed object from a CloudKit record.
    ///
    /// - Parameters:
    ///   - record: CloudKit record to update from.
    func update(from record: CKRecord) throws {
        name = record["name"]
        details = record["details"]
        notes = record["notes"]

        // TODO: this doesn't feel like the optimal approach for this
        if let references = record["members"] as? [CKRecord.Reference] {
            members.map { removeFromMembers($0) }
            for reference in try references.map { try TrainMember.objectForRecordID($0.recordID, in: managedObjectContext!) } {
                addToMembers(reference)
            }
        } else {
            members = nil
        }
    }

    /// Update a CloudKit record from this managed object.
    ///
    /// - Parameters:
    ///   - record: CloudKit record to update.
    ///   - keys: update only these keys (managed object name), or all keys if `nil.
    func updateRecord(_ record: CKRecord, forKeys keys: Set<String>?) {
        if keys?.contains("name") ?? true { record["name"] = name }
        if keys?.contains("details") ?? true { record["details"] = details }
        if keys?.contains("notes") ?? true { record["notes"] = notes }

        if keys?.contains("members") ?? true {
            if let members = members?.array as? [TrainMember] {
                record["members"] = members.compactMap { $0.recordID.map { CKRecord.Reference(recordID: $0, action: .none) } }
            } else {
                record["members"] = nil
            }
        }
    }

}

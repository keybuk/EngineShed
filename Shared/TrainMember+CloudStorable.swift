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

    internal func update(from record: CKRecord) throws {
        isFlipped = record["isFlipped"] ?? false
        title = record["title"]

        if let reference = record["train"] as? CKRecord.Reference {
            train = try Train.forRecordID(reference.recordID, in: managedObjectContext!)
        } else {
            train = nil
        }

        if let reference = record["model"] as? CKRecord.Reference {
            model = try Model.forRecordID(reference.recordID, in: managedObjectContext!)
        } else {
            model = nil
        }
    }

}

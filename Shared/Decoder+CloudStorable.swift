//
//  Decoder+CloudStorable.swift
//  EngineShed
//
//  Created by Scott James Remnant on 6/17/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import CloudKit
import CoreData

extension Decoder : CloudStorable {

    internal func update(from record: CKRecord) throws {
        address = record["address"] ?? 0
        firmwareDate = record["firmwareDate"]
        firmwareVersion = record["firmwareVersion"]
        serialNumber = record["serialNumber"]
        soundAuthor = record["soundAuthor"]
        soundFile = record["soundFile"]

        if let reference = record["model"] as? CKRecord.Reference {
            model = try Model.forRecordID(reference.recordID, in: managedObjectContext!)
        } else {
            model = nil
        }

        if let reference = record["type"] as? CKRecord.Reference {
            type = try DecoderType.forRecordID(reference.recordID, in: managedObjectContext!)
        } else {
            type = nil
        }
    }

}

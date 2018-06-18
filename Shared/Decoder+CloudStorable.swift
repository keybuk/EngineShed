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

        if let _ = record["model"] as? CKRecord.Reference {
            // TODO: model from CKReference
        } else {
            model = nil
        }

        if let _ = record["type"] as? CKRecord.Reference {
            // TODO: type from CKReference
        } else {
            type = nil
        }
    }

}

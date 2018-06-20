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

    internal func update(from record: CKRecord) throws {
        name = record["name"]
        notes = record["notes"]
    }

}

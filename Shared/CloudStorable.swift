//
//  CloudStorable.swift
//  EngineShed
//
//  Created by Scott James Remnant on 6/18/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import CloudKit
import CoreData

protocol CloudStorable : class {

    var recordName: String? { get set }
    var zoneID: NSObject? { get set }
    var systemFields: Data? { get set }

    /// Update record fields from CloudKit record.
    func update(from record: CKRecord) throws

    /// Encode the CloudKit system fields into `systemFields`.
    func encodeSystemFields(from record: CKRecord)

}

extension CloudStorable {

    func encodeSystemFields(from record: CKRecord) {
        let archiver = NSKeyedArchiver(requiringSecureCoding: true)
        record.encodeSystemFields(with: archiver)
        systemFields = archiver.encodedData
    }

}

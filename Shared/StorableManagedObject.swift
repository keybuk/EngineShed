//
//  StorableManagedObject.swift
//  EngineShed
//
//  Created by Scott James Remnant on 6/18/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import CloudKit
import CoreData

/// NSManagedObject that can be stored in CloudKit.
///
/// Each entity that can be stored in CloudKit should provide attributes for the `recordID`,
/// `zoneID`, and `systemFields`. In addition the entity class should declare the `recordType`.
///
/// For handling storage the entity provides a method to update the object from a CloudKit record,
/// and a method to update a CloudKit record from the object.
protocol StorableManagedObject : class, CloudStorable {

    /// CloudKit record type.
    static var recordType: CKRecord.RecordType { get }

    /// CloudKit record ID.
    var recordID: CKRecord.ID? { get set }

    /// CloudKit zone ID.
    var zoneID: CKRecordZone.ID? { get set }

    /// CloudKit system fields.
    var systemFields: Data? { get set }

    /// Update the managed object from a CloudKit record.
    ///
    /// - Parameters:
    ///   - record: CloudKit record to update from.
    func update(from record: CKRecord) throws

    /// Update a CloudKit record from this managed object.
    ///
    /// - Parameters:
    ///   - record: CloudKit record to update.
    ///   - keys: update only these keys (managed object name), or all keys if `nil.
    func updateRecord(_ record: CKRecord, forKeys keys: Set<String>?)

}

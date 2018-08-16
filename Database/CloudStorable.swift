//
//  CloudStorable.swift
//  EngineShed
//
//  Created by Scott James Remnant on 6/20/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import CloudKit

/// Type that can be stored in CloudKit.
///
/// Each entity that can be stored in CloudKit should provide attributes for the `recordID`,
/// `zoneID`, and `systemFields`. In addition the entity class should declare the `recordType`.
///
/// For handling storage the entity provides a method to update the object from a CloudKit record,
/// and a method to update a CloudKit record from the object.
protocol CloudStorable : class {

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
    ///   - keys: update only these keys (managed object name), or all keys if `nil`.
    func updateRecord(_ record: CKRecord, forKeys keys: Set<String>?)

    /// Create a CloudKit record for the type, in the given zone.
    ///
    /// The type should create a `CKRecord.ID` for the provided `zoneID`, and persist it.
    ///
    /// - Parameters:
    ///   - zoneID: record zone for the new record.
    func createRecord(in zoneID: CKRecordZone.ID)

    /// Update the values of the CloudKit record.
    ///
    /// The type should return a `CKRecord` containing the correct record and zone, along with
    /// the values of properties provided in `keys` (which are from the instance's point of view).
    ///
    /// When `keys` is `nil`, the values of all properties should be set.
    ///
    /// - Parameters:
    ///   - keys: set of keys (from the instance's point of view) to store in the record, or `nil`
    ///     when all keys should be set.
    ///
    /// - Returns: `CKRecord` to store in CloudKit, or `nil` if the object cannot be stored.
    func syncToRecord(forKeys keys: Set<String>?) -> CKRecord?

}

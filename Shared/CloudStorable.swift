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
/// For storage in CloudKit a type needs to be able to create its `CKRecord`, including the
/// `recordID`, vend it along with the values for a given set of keys, and supply the `recordID`
/// later for actions including deltion.
///
/// It is not required that all instances of conforming types be stored.
protocol CloudStorable {

    /// Create a CloudKit record for the type, in the given zone.
    ///
    /// If the instance should be stored in CloudKit, the type should create a `CKRecord.ID` for
    /// the provided `zoneID`, and persist it.
    ///
    /// If the instance has no backing record, the implementation may be empty.
    ///
    /// - Parameters:
    ///   - zoneID: record zone for the new record.
    func createRecord(in zoneID: CKRecordZone.ID)

    /// Update the values of the CloudKit record.
    ///
    /// If the instance is stored in CloudKit, the type should return a `CKRecord` containing the
    /// correct record and zone, along with the values of properties provided in `keys` (which are
    /// from the instance's point of view).
    ///
    /// When `keys` is `nil`, the values of all properties should be set.
    ///
    /// - Parameters:
    ///   - keys: set of keys (from the instance's point of view) to store in the record, or `nil`
    ///     when all keys should be set.
    ///
    /// - Returns: `CKRecord` to store in CloudKit, or `nil` if no record should be stored.
    func syncToRecord(forKeys keys: Set<String>?) -> CKRecord?

    /// CloudKit record identifier for the instance.
    ///
    /// `nil` may be returned if the instance has no backing record.
    var recordID: CKRecord.ID? { get }

}

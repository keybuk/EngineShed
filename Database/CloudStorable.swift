//
//  CloudStorable.swift
//  EngineShed
//
//  Created by Scott James Remnant on 6/20/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import CloudKit
import CoreData

/// Type that can be stored in CloudKit.
///
/// Each entity that can be stored in CloudKit should provide attributes for the `recordID`,
/// `zoneID`, and `systemFields`. In addition the entity class should declare the `recordType`.
///
/// For handling storage the entity provides a method to update the object from a CloudKit record,
/// and a method to update a CloudKit record from the object.
protocol CloudStorable : NSManagedObject {

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

}

// When an `NSManagedObject` conforms to `CloudStorable`, provide additional methods to allow it to
// be used by `CloudObserver` and `CloudProvider`.
extension CloudStorable {

    /// Returns an object for a CloudKit record.
    ///
    /// The existing object with the given `recordID` is returned, or if one does not exist, a
    /// new object is created.
    ///
    /// Note the while the newly created object will have the correct `recordID`, any
    /// `systemFields` or values will be missing so it is not possible to sync this to a CloudKit
    /// record without first syncing it from that record.
    ///
    /// - Parameters:
    ///   - recordID: CloudKit record ID for the object.
    ///   - context: managed object context for the fetch and creation.
    ///
    /// - Returns: existing or newly created object.
    static func objectForRecordID(_ recordID: CKRecord.ID, in context: NSManagedObjectContext) throws -> Self {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Self.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "recordID == %@", recordID)

        return try context.performAndWait {
            let objects = try fetchRequest.execute()
            if let object = objects.first as? Self { return object }

            // Create the object, only fill in the record and zone at this point.
            let object = Self(context: context)
            object.recordID = recordID
            object.zoneID = recordID.zoneID
            return object
        }
    }


    // MARK: CloudObserver methods

    /// Sync an object from a CloudKit record.
    ///
    /// The existing object with the given `recordID`, or a newly created object if one does not
    /// exist, is synchronised with the contents of the CloudKit `record`.
    ///
    /// - Parameters:
    ///   - record: CloudKit record to synchronize to the object.
    ///   - context: managed object context for the fetch and creation.
    ///   - updateValues: set to `false` if values in `record` should be ignored, and only the
    ///     object `systemFields` updated.
    static func syncObjectFromRecord(_ record: CKRecord, in context: NSManagedObjectContext, updateValues: Bool = true) throws {
        let object = try objectForRecordID(record.recordID, in: context)
        if updateValues {
            try object.update(from: record)
        }
        object.saveSystemFields(from: record)
    }

    /// Delete all objects for specified CloudKit records.
    ///
    /// - Parameters:
    ///   - recordIDs: Array of CloudKit record IDs to be deleted.
    ///   - context: managed object context for the deletion.
    static func deleteObjectsForRecords(_ recordIDs: [CKRecord.ID], in context: NSManagedObjectContext) throws {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Self.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "recordID IN %@", recordIDs)

        try context.performAndWait {
            let objects = try fetchRequest.execute()
            for case let object as Self in objects {
                context.delete(object)
            }
        }
    }

    /// Delete all objects in specified CloudKit zones.
    ///
    /// - Parameters:
    ///   - zoneIDs: CloudKit zoneIDs in which all records should be deleted.
    ///   - context: managed object context for the deletion.
    static func deleteObjectsForZoneIDs(_ zoneIDs: [CKRecordZone.ID], in context: NSManagedObjectContext) throws {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Self.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "zoneID IN %@", zoneIDs)

        try context.performAndWait {
            let objects = try fetchRequest.execute()
            for case let object as Self in objects {
                context.delete(object)
            }
        }
    }


    // MARK: CloudProvider methods.

    /// Create a CloudKit record in the given zone.
    ///
    /// A new record ID is created automatically and `systemFields` saved so that this object may
    /// now both sync to and from CloudKit.
    ///
    /// - Parameters:
    ///   - zoneID: record zone for the new record.
    func createRecord(in zoneID: CKRecordZone.ID) {
        guard systemFields == nil else { preconditionFailure("Managed object already has a CKRecord") }

        let recordName = UUID().uuidString
        let recordID = CKRecord.ID(recordName: recordName, zoneID: zoneID)
        let record = CKRecord(recordType: Self.recordType, recordID: recordID)

        self.recordID = recordID
        self.zoneID = zoneID

        saveSystemFields(from: record)
    }

    /// Update the values of the CloudKit record.
    ///
    /// Returns the `CKRecord` constructed from `systemFields`, with only the values of object
    /// properties specified in `keys` set.
    ///
    /// When `keys` is `nil`, the values of all properties are set.
    ///
    /// - Parameters:
    ///   - keys: set of object property keys to store in the record, or `nil` when all keys should
    ///     be set.
    ///
    /// - Returns: `CKRecord` to store in CloudKit, or `nil` if `systemFields` is empty or corrupt.
    func syncToRecord(forKeys keys: Set<String>?) -> CKRecord? {
        guard let systemFields = systemFields else { return nil }

        guard let archiver = try? NSKeyedUnarchiver(forReadingFrom: systemFields) else { return nil }
        archiver.requiresSecureCoding = true

        guard let record = CKRecord(coder: archiver) else { return nil }
        archiver.finishDecoding()

        updateRecord(record, forKeys: keys)
        return record
    }


    // MARK: Book-keeping

    /// Save `systemFields` from CloudKit record.
    private func saveSystemFields(from record: CKRecord) {
        let archiver = NSKeyedArchiver(requiringSecureCoding: true)
        record.encodeSystemFields(with: archiver)
        systemFields = archiver.encodedData
    }

}

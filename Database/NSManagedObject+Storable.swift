//
//  NSManagedObject+Storable.swift
//  EngineShed
//
//  Created by Scott James Remnant on 6/20/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import CloudKit
import CoreData

// When an `NSManagedObject` conforms to `CloudStorable`, provide additional methods to allow it to
// be used by `CloudProvider`.
extension CloudStorable where Self : NSManagedObject {

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

        let objects = try context.fetch(fetchRequest)
        if let object = objects.first as? Self { return object }

        // Create the object, only fill in the record and zone at this point.
        let object = Self(context: context)
        object.recordID = recordID
        object.zoneID = recordID.zoneID
        return object
    }

    /// Delete all objects for CloudKit records.
    ///
    /// This may be called for either a set of known `recordIDs`, or for one or more `zoneIDs`.
    ///
    /// Once the deletion is done, changes are merged back to the context `mergeContext`.
    ///
    /// - Parameters:
    ///   - recordIDs: CloudKit record IDs to be deleted, or `nil`.
    ///   - zoneIDs: CloudKit zoneIDs in which all records should be deleted, or `nil`.
    ///   - context: managed object context for the deletion.
    ///   - mergeContext: managed object context to merge changes back to, or `nil`.
    static func deleteObjects(recordIDs: [CKRecord.ID]?, zoneIDs: [CKRecordZone.ID]?, in context: NSManagedObjectContext, mergeTo mergeContext: NSManagedObjectContext?) throws {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Self.fetchRequest()
        if let recordIDs = recordIDs {
            fetchRequest.predicate = NSPredicate(format: "recordID IN %@", recordIDs)
        } else if let zoneIDs = zoneIDs {
            fetchRequest.predicate = NSPredicate(format: "zoneID IN %@", zoneIDs)
        }

        try willDeleteObjects(matching: fetchRequest, in: context)

        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        deleteRequest.resultType = .resultTypeObjectIDs

        let result = try context.execute(deleteRequest) as! NSBatchDeleteResult
        if let deletedObjects = result.result as? [NSManagedObjectID],
            let mergeContext = mergeContext
        {
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: [NSDeletedObjectsKey: deletedObjects], into: [mergeContext])
        }
    }

    /// Save `systemFields` from CloudKit record.
    func saveSystemFields(from record: CKRecord) {
        let archiver = NSKeyedArchiver(requiringSecureCoding: true)
        record.encodeSystemFields(with: archiver)
        systemFields = archiver.encodedData
    }

    /// Create a CloudKit record in the given zone.
    ///
    /// A new record ID is created automatically and `systemFields` saved so that this object may
    /// now both sync to and from CloudKit.
    ///
    /// - Parameters:
    ///   - zoneID: record zone for the new record.
    func createRecord(in zoneID: CKRecordZone.ID) {
        guard systemFields == nil else { fatalError("Managed object already has a CKRecord") }

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

}

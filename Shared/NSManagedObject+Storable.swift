//
//  NSManagedObject+Storable.swift
//  EngineShed
//
//  Created by Scott James Remnant on 6/20/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import CloudKit
import CoreData

// `CloudStorable` conformance is provided for free when it's conformed to by an
// `NSManagedObject` entity type.
//
// In addition an `objectForRecordID(_:in:)` static method is added to fetch or create records
// of the correct entity type.
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

// When `NSManagedObject` conforms to `StorableObjectTranslation`, provide a method to directly
// sync an object. This exists here largely to keep the actual translation function in its own
// file.
extension StorableObjectTranslation where Self : NSManagedObject {

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
        guard let storableClass = classForRecordType(record.recordType) else { return }

        let object = try storableClass.objectForRecordID(record.recordID, in: context)
        if updateValues {
            try object.update(from: record)
        }
        object.saveSystemFields(from: record)
    }

}

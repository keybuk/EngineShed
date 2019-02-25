//
//  NSManagedObject+StorableObjectTranslation.swift
//  EngineShed
//
//  Created by Scott James Remnant on 8/16/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import CloudKit
import CoreData

/// When `NSManagedObject` conforms to `StorableObjectTranslation`, provide methods to act on
/// objects and group of objects without knowing the underlying entity type.
///
/// These methods map directly to methods of the same name and equivalent type signature in
/// `CloudStorable`, after expanding the correct entity type.
extension StorableObjectTranslation where Self : NSManagedObject {

    /// Returns the correct `NSManagedObject` subclass for the entity matching `recordType`.
    static func classForRecordType(_ recordType: CKRecord.RecordType) -> CloudStorableObject.Type? {
        guard let (_, storableClass) = storableTypes.first(where: { $0.0 == recordType }) else { return nil }
        return storableClass
    }

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
        try storableClass.syncObjectFromRecord(record, in: context, updateValues: updateValues)        
    }

    /// Delete all objects for CloudKit records.
    ///
    /// - Parameters:
    ///   - deletedRecords: Array of CloudKit record IDs mapped to a set of CloudKit record types.
    ///   - zoneIDs: CloudKit zoneIDs in which all records should be deleted, or `nil`.
    ///   - context: managed object context for the deletion.
    static func deleteObjectsForRecords(_ deletedRecords: [CKRecord.RecordType: [CKRecord.ID]], in context: NSManagedObjectContext) throws {
        for (recordType, recordIDs) in deletedRecords {
            guard let storableClass = classForRecordType(recordType) else { continue }
            try storableClass.deleteObjectsForRecords(recordIDs, in: context)
        }
    }

    /// Delete all objects in CloudKit zones.
    ///
    /// - Parameters:
    ///   - zoneIDs: CloudKit zoneIDs in which all records should be deleted.
    ///   - context: managed object context for the deletion.
    static func deleteObjectsForZoneIDs(_ zoneIDs: [CKRecordZone.ID], in context: NSManagedObjectContext) throws {
        for (_, storableClass) in storableTypes {
            try storableClass.deleteObjectsForZoneIDs(zoneIDs, in: context)
        }
    }

}

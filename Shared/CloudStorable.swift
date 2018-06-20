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

    /// CloudKit record type.
    static var recordType: CKRecord.RecordType { get }

    /// CloudKit record ID.
    ///
    /// Used to lookup the managed object for a record.
    var recordID: CKRecord.ID? { get set }

    /// CloudKit zone ID.
    ///
    /// Used when a zone is deleted.
    var zoneID: CKRecordZone.ID? { get set }

    /// CloudKit system fields.
    ///
    /// Access through `record`.
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

    /// Returns a CKRecord from the CloudKit system fields.
    var record: CKRecord? { get set }

    /// Create a CKRecord and save to the CloudKit system fields.
    @discardableResult
    func createRecordInZoneID(_ zoneID: CKRecordZone.ID) -> CKRecord

}

extension CloudStorable {

    /// Returns a CKRecord from the CloudKit system fields.
    var record: CKRecord? {
        get {
            guard let systemFields = systemFields else { return nil }
            guard let archiver = try? NSKeyedUnarchiver(forReadingFrom: systemFields) else { return nil }
            archiver.requiresSecureCoding = true

            guard let record = CKRecord(coder: archiver) else { return nil }
            return record
        }

        set {
            if let newValue = newValue {
                let archiver = NSKeyedArchiver(requiringSecureCoding: true)
                newValue.encodeSystemFields(with: archiver)
                systemFields = archiver.encodedData
            } else {
                systemFields = nil
            }
        }
    }

    /// Create a CKRecord and save to the CloudKit system fields.
    @discardableResult
    func createRecordInZoneID(_ zoneID: CKRecordZone.ID) -> CKRecord {
        guard self.record == nil else { fatalError("Managed object already has a CKRecord") }

        let recordName = UUID().uuidString
        let recordID = CKRecord.ID(recordName: recordName, zoneID: zoneID)
        let record = CKRecord(recordType: Self.recordType, recordID: recordID)

        self.recordID = recordID
        self.zoneID = zoneID
        self.record = record

        return record
    }

}

extension CloudStorable where Self : NSManagedObject {

    /// Return or create record for a stored CloudKit object.
    ///
    /// If a record already exists, it will be returned, otherwise a new record is created and
    /// inserted into the context.
    ///
    /// - Parameters:
    ///   - recordID: CloudKit record identifier.
    ///   - context: `NSManagedObjectContext` for the query and to create the record in.
    ///
    /// - Returns: existing or new record.
    static func forRecordID(_ recordID: CKRecord.ID, in context: NSManagedObjectContext, createIfNeeded: Bool = true) throws -> Self {
        if let result = try fetchRecordID(recordID, in: context) {
            return result
        } else {
            let result = Self(context: context)

            result.recordID = recordID
            result.zoneID = recordID.zoneID

            return result
        }
    }

    /// Return existing record for a stored CloudKit object.
    ///
    /// - Parameters:
    ///   - recordID: CloudKit record identifier.
    ///   - context: `NSManagedObjectContext` for the query and to create the record in.
    ///
    /// - Returns: existing record or `nil` if none exists.
    static func fetchRecordID(_ recordID: CKRecord.ID, in context: NSManagedObjectContext) throws -> Self? {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Self.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "recordID == %@", recordID)

        let results = try context.fetch(fetchRequest)
        return results.first as? Self
    }

}

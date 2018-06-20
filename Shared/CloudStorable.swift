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

    var recordName: String? { get set }
    var zoneID: NSObject? { get set }
    var systemFields: Data? { get set }

    /// Update record fields from CloudKit record.
    func update(from record: CKRecord) throws

    /// Encode the CloudKit system fields into `systemFields`.
    func encodeSystemFields(from record: CKRecord)

}

extension CloudStorable {

    internal func encodeSystemFields(from record: CKRecord) {
        let archiver = NSKeyedArchiver(requiringSecureCoding: true)
        record.encodeSystemFields(with: archiver)
        systemFields = archiver.encodedData
    }

}

extension CloudStorable where Self : NSManagedObject {

    /// Return record for a stored CloudKit object.
    ///
    /// If a record already exists, it will be returned, otherwise a new record is created and
    /// inserted into the context.
    ///
    /// - Parameters:
    ///   - recordID: CloudKit record identifier.
    ///   - context: `NSManagedObjectContext` for the query and to create the record in.
    ///
    /// - Returns: existing or new record.
    static func forRecordID(_ recordID: CKRecord.ID, in context: NSManagedObjectContext) throws -> Self {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Self.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "recordName == %@ AND zoneID == %@", recordID.recordName, recordID.zoneID)

        let results = try context.fetch(fetchRequest)
        if let result = results.first as? Self { return result }

        let result = Self(context: context)

        result.recordName = recordID.recordName
        result.zoneID = recordID.zoneID

        return result
    }

}

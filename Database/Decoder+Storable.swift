//
//  Decoder+Storable.swift
//  EngineShed
//
//  Created by Scott James Remnant on 6/17/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import CloudKit
import CoreData

extension Decoder : CloudStorable {

    /// CloudKit record type.
    static let recordType = "Decoder"

    /// Update the managed object from a CloudKit record.
    ///
    /// - Parameters:
    ///   - record: CloudKit record to update from.
    func update(from record: CKRecord) throws {
        address = record["address"] ?? 0
        firmwareVersion = record["firmwareVersion"]
        serialNumber = record["serialNumber"]
        soundAuthor = record["soundAuthor"]
        soundProject = record["soundProject"]
        soundProjectVersion = record["soundProjectVersion"]
        soundSettings = record["soundSettings"]

        if let data = record["firmwareDate"] as? Data,
            let unarchiver = try? NSKeyedUnarchiver(forReadingFrom: data)
        {
            firmwareDate = unarchiver.decodeObject(of: NSDateComponents.self, forKey: "FirmwareDate")
            unarchiver.finishDecoding()
        }

        if let reference = record["model"] as? CKRecord.Reference {
            model = try Model.objectForRecordID(reference.recordID, in: managedObjectContext!)
        } else {
            model = nil
        }

        if let reference = record["type"] as? CKRecord.Reference {
            type = try DecoderType.objectForRecordID(reference.recordID, in: managedObjectContext!)
        } else {
            type = nil
        }
    }

    /// Update a CloudKit record from this managed object.
    ///
    /// - Parameters:
    ///   - record: CloudKit record to update.
    ///   - keys: update only these keys (managed object name), or all keys if `nil.
    func updateRecord(_ record: CKRecord, forKeys keys: Set<String>?) {
        if keys?.contains("address") ?? true { record["address"] = address }
        if keys?.contains("firmwareVersion") ?? true { record["firmwareVersion"] = firmwareVersion }
        if keys?.contains("serialNumber") ?? true { record["serialNumber"] = serialNumber }
        if keys?.contains("soundAuthor") ?? true { record["soundAuthor"] = soundAuthor }
        if keys?.contains("soundProject") ?? true { record["soundProject"] = soundProject }
        if keys?.contains("soundProjectVersion") ?? true { record["soundProjectVersion"] = soundProjectVersion }
        if keys?.contains("soundSettings") ?? true { record["soundSettings"] = soundSettings }

        if keys?.contains("firmwareDate") ?? true {
            record["firmwareDate"] = firmwareDate.map {
                let archiver = NSKeyedArchiver(requiringSecureCoding: true)
                archiver.encode($0, forKey: "FirmwareDate")
                archiver.finishEncoding()
                return archiver.encodedData as NSData
            }
        }
    
        if keys?.contains("model") ?? true {
            if let recordID = model?.recordID {
                record["model"] = CKRecord.Reference(recordID: recordID, action: .none)
            } else {
                record["model"] = nil
            }
        }

        if keys?.contains("type") ?? true {
            if let recordID = type?.recordID {
                record["type"] = CKRecord.Reference(recordID: recordID, action: .deleteSelf)
            } else {
                record["type"] = nil
            }
        }
    }

}

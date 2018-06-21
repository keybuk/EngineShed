//
//  DetailPart+Storable.swift
//  EngineShed
//
//  Created by Scott James Remnant on 6/19/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import CloudKit
import CoreData

// DetailPart doesn't conform to the wider StorableManagedObject type because it doesn't
// represent a CloudKit record. But by conforming to `CloudStorable` it can redirect its storage
// to the `detailPartsFitted` record value of the underlying model.
extension DetailPart : CloudStorable {

    var recordID: CKRecord.ID? {
        return nil
    }

    func createRecord(in zoneID: CKRecordZone.ID) {}

    func syncToRecord(forKeys keys: Set<String>?) -> CKRecord? {
        guard keys?.contains("isFitted") ?? true else { return nil }

        return model?.syncToRecord(forKeys: [ "detailPartsFitted" ])
    }

}

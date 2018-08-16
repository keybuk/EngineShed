//
//  NSManagedObject+TypeAliases.swift
//  EngineShed
//
//  Created by Scott James Remnant on 6/20/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import CloudKit
import CoreData

extension NSManagedObject {

    // Custom classes in the data model can't contain `.`, so create underscored aliases for them.
    // rdar://41309196
    public typealias CKRecord_ID = CKRecord.ID
    public typealias CKRecordZone_ID = CKRecordZone.ID

}

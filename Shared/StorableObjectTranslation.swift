//
//  StorableObjectTranslation.swift
//  EngineShed
//
//  Created by Scott James Remnant on 6/20/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import CloudKit
import CoreData

/// Permit translation from a `CKRecord.RecordType` to an `NSManagedObject` subclass that conforms
/// to `StorableManagedObject`.
protocol StorableObjectTranslation {

    /// A type that confirms to both `StorableManagedObject` and `NSManagedObject`.
    typealias StorableObjectType = StorableManagedObject & NSManagedObject

    /// Returns the correct `NSManagedObject` subclass for the entity matching `recordType`.
    static func classForRecordType(_ recordType: CKRecord.RecordType) -> StorableObjectType.Type?

}

//
//  NSManagedObject+RecordType.swift
//  EngineShed
//
//  Created by Scott James Remnant on 6/19/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import CloudKit
import CoreData

extension NSManagedObject : StorableObjectTranslation {

    /// Returns the correct `NSManagedObject` subclass for the entity matching `recordType`.
    static func classForRecordType(_ recordType: CKRecord.RecordType) -> CloudStorableObject.Type? {
        switch recordType {
        case Purchase.recordType: return Purchase.self
        case Model.recordType: return Model.self
        case DecoderType.recordType: return DecoderType.self
        case Decoder.recordType: return Decoder.self
        case Train.recordType: return Train.self
        case TrainMember.recordType: return TrainMember.self
        default: return nil
        }
    }

}

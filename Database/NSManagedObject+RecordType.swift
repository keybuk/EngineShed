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

    static let storableTypes: [(CKRecord.RecordType, CloudStorableObject.Type)] = [
        // Model goes first in this list so that we get a chance to delete images; otherwise
        // cascade rules in batch requests will take away our chance.
        (Model.recordType, Model.self),
        (Purchase.recordType, Purchase.self),
        (DecoderType.recordType, DecoderType.self),
        (Decoder.recordType, Decoder.self),
        (Train.recordType, Train.self),
        (TrainMember.recordType, TrainMember.self)
    ]

}

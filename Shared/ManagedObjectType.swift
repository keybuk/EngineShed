//
//  ManagedObjectType.swift
//  EngineShed
//
//  Created by Scott James Remnant on 6/19/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import CloudKit
import CoreData

typealias StorableManagedObject = CloudStorable & NSManagedObject

let managedObjectType: [CKRecord.RecordType: StorableManagedObject.Type] = [
    Purchase.recordType: Purchase.self,
    Model.recordType: Model.self,
    DecoderType.recordType: DecoderType.self,
    Decoder.recordType: Decoder.self,
    Train.recordType: Train.self,
    TrainMember.recordType: TrainMember.self
]

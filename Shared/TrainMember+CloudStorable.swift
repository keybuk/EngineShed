//
//  TrainMember+CloudStorable.swift
//  EngineShed
//
//  Created by Scott James Remnant on 6/17/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import CloudKit
import CoreData

extension TrainMember : CloudStorable {

    func update(from record: CKRecord) throws {
        isFlipped = record["isFlipped"] ?? false
        title = record["title"]

        if let _ = record["train"] as? CKRecord.Reference {
            // TODO: train from CKReference
        } else {
            train = nil
        }

        if let _ = record["model"] as? CKRecord.Reference {
            // TODO: model from CKReference
        } else {
            model = nil
        }
    }

}

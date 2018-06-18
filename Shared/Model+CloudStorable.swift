//
//  Model+CloudStorable.swift
//  EngineShed
//
//  Created by Scott James Remnant on 6/17/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import CloudKit
import CoreData

extension Model : CloudStorable {

    func update(from record: CKRecord) throws {
        modelClass = record["class"]
        classificationRawValue = record["classification"] ?? 0
        details = record["details"]
        dispositionRawValue = record["disposition"] ?? 0
        eraRawValue = record["era"] ?? 0
        lastOil = record["lastOil"]
        lastRun = record["lastRun"]
        livery = record["livery"]
        motor = record["motor"]
        name = record["name"]
        notes = record["notes"]
        number = record["number"]
        socket = record["socket"]
        speaker = record["speaker"]

        if let asset = record["image"] as? CKAsset {
            image = ModelImage(contentsOf: asset.fileURL)
        } else {
            image = nil
        }

        // TODO: couplings
        // TODO: detailParts
        // TODO: features
        // TODO: lightings
        // TODO: modifications
        // TODO: speakerFittings
        // TODO: tasks

        if let _ = record["purchase"] as? CKRecord.Reference {
            // TODO: purchase from CKReference
        } else {
            purchase = nil
        }
    }

}

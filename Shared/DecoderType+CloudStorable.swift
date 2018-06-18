//
//  DecoderType+CloudStorable.swift
//  EngineShed
//
//  Created by Scott James Remnant on 6/17/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import CloudKit
import CoreData

extension DecoderType : CloudStorable {

    internal func update(from record: CKRecord) throws {
        hasRailCom = record["hasRailCom"] ?? false
        hasSound = record["hasSound"] ?? false
        isProgrammable = record["isProgrammable"] ?? false
        manufacturer = record["manufacturer"]
        minimumStock = record["minimumStock"] ?? 0
        productCode = record["productCode"]
        productDescription = record["productDescription"]
        productFamily = record["productFamily"]
        socket = record["socket"]
    }

}

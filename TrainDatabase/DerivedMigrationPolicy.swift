//
//  DerivedMigrationPolicy.swift
//  TrainDatabase
//
//  Created by Scott James Remnant on 1/25/20.
//  Copyright © 2020 Scott James Remnant. All rights reserved.
//

import Foundation
import CoreData

final class PurchaseDerivedMigrationPolicy: NSEntityMigrationPolicy {

    override func createDestinationInstances(forSource sInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        try super.createDestinationInstances(forSource: sInstance, in: mapping, manager: manager)

        guard let dInstance = manager.destinationInstances(forEntityMappingName: mapping.name, sourceInstances: [sInstance]).first
            else { fatalError("must return purchase") }

        let temporary = Purchase(entity: manager.sourceEntity(for: mapping)!, insertInto: nil)

        let catalogNumber = dInstance.value(forKey: "catalogNumber") as! String?
        dInstance.setValue(catalogNumber.map { temporary.makeCatalogNumberPrefix(from: $0) }, forKey: "catalogNumberPrefix")

        let date = dInstance.value(forKey: "date") as! DateComponents?
        dInstance.setValue(temporary.makeDateForGrouping(from: date), forKey: "dateForGrouping")
        dInstance.setValue(temporary.makeDateForSort(from: date), forKey: "dateForSort")
    }
}

final class DecoderTypeDerivedMigrationPolicy: NSEntityMigrationPolicy {

    override func createDestinationInstances(forSource sInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        try super.createDestinationInstances(forSource: sInstance, in: mapping, manager: manager)

        guard let dInstance = manager.destinationInstances(forEntityMappingName: mapping.name, sourceInstances: [sInstance]).first
            else { fatalError("must return decoder type") }

        dInstance.setValue(NSNumber(integerLiteral: 0), forKey: "remainingStock")

//        decoderType.remainingStock = decoderType.makeRemainingStock()
    }

}

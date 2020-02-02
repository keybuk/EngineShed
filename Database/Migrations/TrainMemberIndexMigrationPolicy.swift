//
//  TrainMemberIndexMigrationPolicy.swift
//  EngineShed
//
//  Created by Scott James Remnant on 2/1/20.
//  Copyright © 2020 Scott James Remnant. All rights reserved.
//

import Foundation
import CoreData

final class TrainMemberIndexMigrationPolicy: NSEntityMigrationPolicy {
    override func createRelationships(forDestination dInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        try super.createRelationships(forDestination: dInstance, in: mapping, manager: manager)

        guard let sInstance = manager.sourceInstances(forEntityMappingName: mapping.name, destinationInstances: [dInstance]).first else { preconditionFailure("Missing source instance") }
        guard let sTrain = sInstance.value(forKey: "train") as? NSManagedObject else { preconditionFailure("Missing source train") }

        let objectIDs = sTrain.objectIDs(forRelationshipNamed: "members")
        guard let index = objectIDs.firstIndex(of: sInstance.objectID) else { preconditionFailure("ObjectID missing in source members list") }

        let enumeratedIndex = objectIDs.distance(from: objectIDs.startIndex, to: index)
        dInstance.setPrimitiveValue(NSNumber(integerLiteral: enumeratedIndex), forKey: "index")
    }
}


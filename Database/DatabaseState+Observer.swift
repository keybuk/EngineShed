//
//  DatabaseState+Observer.swift
//  EngineShed
//
//  Created by Scott James Remnant on 12/29/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

// Extend the DatabaseState core data object to support the methods required by `CloudObserver`.
extension DatabaseState {

    enum Error : Swift.Error {
        /// Inconsistent state caused by multiple sync tokens for the same database.
        case multipleTokens
    }

    /// Returns the `DatabaseState` object for the CloudKit database.
    ///
    /// Fetches the current object based on the `scopeRawValue` matching `database.databaseScope`,
    /// or creates a new object.
    ///
    /// - Parameters:
    ///   - context: managed object context for fetch and creation.
    ///   - database: CloudKit database to fetch or create record for.
    /// - Returns: `DatabaseState` object in `context`.
    static func fetchOrCreate(context: NSManagedObjectContext, for database: CKDatabase) throws -> DatabaseState {
        let fetchRequest: NSFetchRequest<DatabaseState> = DatabaseState.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "scopeRawValue = %d", database.databaseScope.rawValue)

        return try context.performAndWait {
            let results = try fetchRequest.execute()
            if results.count > 1 {
                throw Error.multipleTokens
            } else if results.count > 0 {
                return results.first!
            } else {
                let databaseState = DatabaseState(context: context)
                databaseState.scopeRawValue = Int16(truncatingIfNeeded: database.databaseScope.rawValue)
                return databaseState
            }
        }
    }

    /// Returns the `ZoneState` object within this database for the given Zone.
    ///
    /// Fetches the current object based on the `zoneID` or creates a new object.
    ///
    /// - Parameters:
    ///   - zoneID: CloudKit zone identifier.
    /// - Returns: `ZoneState` object from `zoneStates`.
    func stateForZoneWithID(_ zoneID: CKRecordZone.ID) throws -> ZoneState {
        let fetchRequest: NSFetchRequest<ZoneState> = ZoneState.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "databaseState = %@ AND zoneID = %@", self, zoneID)

        return try managedObjectContext!.performAndWait {
            let results = try fetchRequest.execute()
            if results.count > 1 {
                throw ZoneState.Error.multipleTokens
            } else if results.count > 0 {
                return results.first!
            } else {
                let zoneState = ZoneState(context: managedObjectContext!)
                zoneState.databaseState = self
                zoneState.zoneID = zoneID
                return zoneState
            }
        }
    }

    /// Returns the set of zones from `zoneStates` that have pending changes.
    ///
    /// - Returns: array of `ZoneState` where `isDirty` is `true`.
    func statesForDirtyZones() throws -> [ZoneState] {
        let fetchRequest: NSFetchRequest<ZoneState> = ZoneState.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "databaseState = %@ AND isDirty = TRUE", self)

        return try managedObjectContext!.performAndWait {
            return try fetchRequest.execute()
        }
    }

    /// Returns the set of zones from `zoneStates` that are pending deletion.
    ///
    /// - Returns: array of `ZoneState` where `shouldDelete` is `true`.
    func statesForDeletedZones() throws -> [ZoneState] {
        let fetchRequest: NSFetchRequest<ZoneState> = ZoneState.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "databaseState = %@ AND shouldDelete = TRUE", self)

        return try managedObjectContext!.performAndWait {
            return try fetchRequest.execute()
        }
    }

}

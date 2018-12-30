//
//  ZoneState+Provider.swift
//  EngineShed
//
//  Created by Scott James Remnant on 12/30/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

// Extend the ZoneState core data object to support the methods required by `CloudProvider`.
extension ZoneState {

    enum Error : Swift.Error {
        /// Inconsistent state causde by multiple sync tokens for the same zone.
        case multipleTokens
    }

    /// Returns the `ZoneState` object for the given zone.
    ///
    /// Fetches the current object based on the `zoneID` where the database `scopeRawValue`
    /// matches `database.databaseScope`.
    ///
    /// - Parameters:
    ///   - context: managed object context for fetch.
    ///   - zoneID: identifier of zone to fetch.
    ///   - database: CloudKit database to fetch record for.
    /// - Returns: `ZoneState` object in `context`, or `nil` if no such record.
    static func fetch(context: NSManagedObjectContext, for zoneID: CKRecordZone.ID, in database: CKDatabase) throws -> ZoneState? {
        let fetchRequest: NSFetchRequest<ZoneState> = ZoneState.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "zoneID == %@ AND databaseState.scopeRawValue == %d", zoneID, database.databaseScope.rawValue)
        
        return try context.performAndWait {
            let results = try fetchRequest.execute()
            if results.count > 1 {
                throw Error.multipleTokens
            } else {
                return results.first
            }
        }
    }

}

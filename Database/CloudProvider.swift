//
//  CloudProvider.swift
//  EngineShed
//
//  Created by Scott James Remnant on 6/17/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import Foundation
import CloudKit
import CoreData
import Dispatch

// FIXME: this class has no way to report errors

/// Observes changes to a local store, and synchronize to a database stored in CloudKit.
///
/// Changes to the local store are observed using notifications on the core data managed object
/// context:
///
///     provider.observeChanges()
///
/// Each time the view context is saved, the set of inserted, updated, and deleted objects is
/// collated, and turned into a modify records operation send to the server.
///
/// Observing changes is done in two parts due to the differences between notifications; in
/// "will save" the set of changed keys is available for updated objects, while in "did save"
/// the full set of objects is known, but not the changed keys.
///
/// When sending the data to the cloud, a long-lived operation is used that can last beyond the
/// session or application lifetime. On resume, it's necessary to obtain the results from these.
///
///     provider.resumeLongLivedOperations()
///
/// After the data is received by the servers, changes to the record system fields are usually
/// necessary; these are performed on a background
///
/// # NSManagedObject Entity Requirements
/// In order to synchronize changes from the local store, this class requires that
/// `NSManagedObject` entities conform to `CloudStorable` to use the following methods:
///  * `Entity.createRecord(in:)`
///  * `Entity.syncToRecord(forKeys:)`
///  * `Entity.syncObjectFromRecord(:in:updateValues:)`
public final class CloudProvider {

    /// Database container to synchronize to.
    public private(set) var container: CKContainer
    
    /// Database to synchronize to.
    public private(set) var database: CKDatabase
    
    /// Persistent container of local store to observe.
    public private(set) var persistentContainer: NSPersistentContainer

    /// Identifier of record zone to synchronize to.
    let zoneID = CKRecordZone.ID(zoneName: "EngineShed")

    /// Key to ignore contexts and avoid sync loops.
    static let ignoreChangesKey = "EngineShedIgnoreChanges"
    
    public init(container: CKContainer, database: CKDatabase, persistentContainer: NSPersistentContainer) {
        self.container = container
        self.database = database
        self.persistentContainer = persistentContainer
    }

    
    // MARK: - NSManagedObjectContext notifications
    
    // Subscribe to Core Data notifications to watch for changes.
    public func observeChanges() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(managedObjectContextObjectsWillSave(notification:)), name: NSNotification.Name.NSManagedObjectContextWillSave, object: nil)
        notificationCenter.addObserver(self, selector: #selector(managedObjectContextObjectsDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
    }
    
    /// Set of changed keys for each updated object.
    var pendingUpdates: [NSManagedObjectID: Set<String>]? = nil

    @objc
    func managedObjectContextObjectsWillSave(notification: NSNotification) {
        guard let context = notification.object as? NSManagedObjectContext else { return }
        guard context.persistentStoreCoordinator == persistentContainer.persistentStoreCoordinator else { return }

        if let ignoreChanges = context.userInfo[CloudProvider.ignoreChangesKey] as? Bool,
            ignoreChanges { return }

        // Create CKRecord objects for newly inserted objects as part of the save action, rather
        // than after, so in the case of retry after a failure, we send an update for the same
        // object rather than duplicating it.
        for object in context.insertedObjects {
            if let storable = object as? NSManagedObject & CloudStorable {
                storable.createRecord(in: zoneID)
            }
        }

        // The set of changed keys is not available in DidSave, so save them here; but only the
        // keys because validation takes place between WillSave and DidSave.
        pendingUpdates = Dictionary(uniqueKeysWithValues: context.updatedObjects.map {
            ($0.objectID, Set($0.changedValues().keys))
        })
    }

    @objc
    func managedObjectContextObjectsDidSave(notification: NSNotification) {
        guard let context = notification.object as? NSManagedObjectContext else { return }
        guard context.persistentStoreCoordinator == persistentContainer.persistentStoreCoordinator else { return }
        
        if let ignoreChanges = context.userInfo[CloudProvider.ignoreChangesKey] as? Bool,
            ignoreChanges { return }

        guard let userInfo = notification.userInfo else { return }

        var saveRecords: [CKRecord] = []
        var deleteRecordIDs: [CKRecord.ID] = []

        // Save all of the keys of newly inserted objects that can be synchronized.
        if let insertedObjects = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject> {
            for object in insertedObjects {
                if let storable = object as? NSManagedObject & CloudStorable,
                    let record = storable.syncToRecord(forKeys: nil)
                {
                    saveRecords.append(record)
                }
            }
        }

        if let updatedObjects = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject> {
            for object in updatedObjects {
                guard !object.isInserted else { preconditionFailure("Object inserted and updated") }
                let changedKeys = pendingUpdates?[object.objectID]

                // Retrieve the set of changed keys recorded in the WillSave notification and
                // only update the record using those.
                if let storable = object as? NSManagedObject & CloudStorable,
                    let record = storable.syncToRecord(forKeys: changedKeys)
                {
                    saveRecords.append(record)
                }
            }
        }

        if let deletedObjects = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject> {
            for object in deletedObjects {
                guard !object.isInserted && !object.isUpdated else { preconditionFailure("Object deleted and inserted or updated") }
                if let storable = object as? NSManagedObject & CloudStorable,
                    let recordID = storable.recordID
                {
                    deleteRecordIDs.append(recordID)
                }
            }
        }

        if !saveRecords.isEmpty || !deleteRecordIDs.isEmpty {
            modifyRecords(recordsToSave: saveRecords, recordIDsToDelete: deleteRecordIDs)
        }
        pendingUpdates = nil
    }

    
    // MARK: - CloudKit operations
    
    /// Send local object changes to the database.
    ///
    /// - Parameters:
    ///   - recordsToSave: CloudKit records to save.
    ///   - recordIDsToDelete: identifiers of CloudKit records to delete.
    func modifyRecords(recordsToSave: [CKRecord], recordIDsToDelete: [CKRecord.ID]) {
        // Create a single operation to modify all of the records at once.
        let operation = CKModifyRecordsOperation(recordsToSave: recordsToSave, recordIDsToDelete: recordIDsToDelete)
        operation.savePolicy = .ifServerRecordUnchanged
        operation.configuration.isLongLived = true

        operation.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
            if let error = error as? CKError,
                error.code == .limitExceeded
            {
                print("Limit exceeded, splitting request in half")
                let s = recordsToSave.count / 2
                let d = recordIDsToDelete.count / 2

                self.modifyRecords(recordsToSave: Array(recordsToSave[..<s]), recordIDsToDelete: Array(recordIDsToDelete[..<d]))
                self.modifyRecords(recordsToSave: Array(recordsToSave[s...]), recordIDsToDelete: Array(recordIDsToDelete[d...]))
            } else if let error = error {
                fatalError("Couldn't modify records: \(error)")
            }

            self.handleModifyCompletion(savedRecords: savedRecords, deletedRecordIDs: deletedRecordIDs)
        }

        // Create the primary zone before we modify records, but for performance reasons, only
        // do this if we don't think it exists, or we know it's been deleted and wasn't purged.
        // TODO(SE-0230): if try? ... == nil
        let zoneState = try? ZoneState.fetch(context: persistentContainer.viewContext, for: zoneID, in: database)
        if zoneState == nil || zoneState! == nil || (zoneState!!.shouldDelete && !zoneState!!.isPurged) {
            let zoneOperation = createZoneOperation()
            operation.addDependency(zoneOperation)
        }

        operation.qualityOfService = .utility
        database.add(operation)
        print("Modify \(operation)")
    }

    /// Commit results of a modification to the database.
    ///
    /// - Parameters:
    ///   - savedRecords: CloudKit records that were saved.
    ///   - deletedRecordIDs: identifiers of CloudKit records that were deleted.
    func handleModifyCompletion(savedRecords: [CKRecord]?, deletedRecordIDs: [CKRecord.ID]?) {
        // Perform system field updates on a background context.
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.undoManager = nil
        context.userInfo[CloudProvider.ignoreChangesKey] = true

        if let savedRecords = savedRecords {
            debugPrint(savedRecords)
            do {
                for record in savedRecords {
                    try NSManagedObject.syncObjectFromRecord(record, in: context, updateValues: false)
                }

                try context.save()
            } catch {
                fatalError("Failed to write back: \(error)")
            }
        }

        if let deletedRecordIDs = deletedRecordIDs {
            debugPrint(deletedRecordIDs)
        }
    }

    /// Create the primary zone for our records.
    func createZoneOperation() -> CKDatabaseOperation {
        // Create a zone modify operation for our primary zone, which should create it if needed.
        let zone = CKRecordZone(zoneID: zoneID)
        let operation = CKModifyRecordZonesOperation(recordZonesToSave: [zone], recordZoneIDsToDelete: nil)
        
        operation.modifyRecordZonesCompletionBlock = {
            savedZones, deletedZoneIDs, error in
            if let error = error {
                // Errors creating the zone should end up appearing in the record modification,
                // so rather than bailing out, just move on.
                print("Modify zone error: \(error)")
            } else {
                // Record `nil` for the change token of any zone we created, until we find out
                // what the token really is later on.
// FIXME: I don't remember why I did this, and whether it's necessary anymore.
//                if let savedZones = savedZones {
//                    for zone in savedZones {
//                        if self.zoneServerChangeToken.index(forKey: zone.zoneID) == nil {
//                            self.zoneServerChangeToken.updateValue(nil, forKey: zone.zoneID)
//                        }
//                    }
//                }
            }
        }
        
        operation.qualityOfService = .utility
        database.add(operation)
        
        return operation
    }
    
    // Fetch and resume all of the long-lived operations.
    public func resumeLongLivedOperations() {
        container.fetchAllLongLivedOperationIDs { (operationIDs, error) in
            if let error = error {
                print("Failed to fetch long-lived operations: \(error)")
            } else if let operationIDs = operationIDs {
                for operationID in operationIDs {
                    self.container.fetchLongLivedOperation(withID: operationID) { (operation, error) in
                        if let error = error {
                            print("Long-lived operation \(operationID) failed: \(error)")
                        } else if let operation = operation as? CKModifyRecordsOperation {
                            operation.modifyRecordsCompletionBlock = { (savedRecords, deletedRecordIDs, error) in
                                if let error = error {
                                    print("Resuming long-lived modify operation \(operationID) failed: \(error)")
                                } else {
                                    self.handleModifyCompletion(savedRecords: savedRecords, deletedRecordIDs: deletedRecordIDs)
                                }
                            }
                            
                            print("Resuming long-lived modify operation \(operationID)")
                            self.database.add(operation)
                        } else if let operation = operation {
                            print("Resuming long-lived operation \(operationID)")
                            self.container.add(operation)
                        }
                    }
                }
            }
        }
    }
    
}

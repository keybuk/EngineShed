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
    var container: CKContainer
    
    /// Database to synchronize to.
    var database: CKDatabase
    
    /// Persistent container of local store to observe.
    var persistentContainer: NSPersistentContainer

    /// Managed object types to be stored.
    var storableTypes: [(NSManagedObject & CloudStorable).Type]

    /// Delegate to receive notification of events.
    public var delegate: CloudProviderDelegate?

    /// Identifier of record zone to synchronize to.
    let zoneID = CKRecordZone.ID(zoneName: "EngineShed")

    /// Key to ignore contexts and avoid sync loops.
    static let ignoreChangesKey = "EngineShedIgnoreChanges"
    
    init(container: CKContainer, database: CKDatabase, persistentContainer: NSPersistentContainer, storableTypes: [(NSManagedObject & CloudStorable).Type]) {
        self.container = container
        self.database = database
        self.persistentContainer = persistentContainer
        self.storableTypes = storableTypes
    }

    
    // MARK: - NSManagedObjectContext notifications
    
    // Subscribe to Core Data notifications to watch for changes.
    public func observeChanges() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(managedObjectContextObjectsWillSave), name: NSNotification.Name.NSManagedObjectContextWillSave, object: nil)
        notificationCenter.addObserver(self, selector: #selector(managedObjectContextObjectsDidSave), name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
    }
    
    /// Set of changed keys for each updated object.
    var pendingUpdates: [NSManagedObjectID: Set<String>]? = nil

    @objc
    func managedObjectContextObjectsWillSave(_ notification: Notification) {
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
    func managedObjectContextObjectsDidSave(_ notification: Notification) {
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
                if let delegate = self.delegate {
                    print("Couldn't modify records: \(error)")
                    delegate.cloudProvider(self, didFailWithError: error)
                    return
                } else {
                    fatalError("Couldn't modify records: \(error)")
                }
            }

            self.handleModifyCompletion(savedRecords: savedRecords, deletedRecordIDs: deletedRecordIDs)
        }

        // Create the primary zone before we modify records, but for performance reasons, only
        // do this if we don't think it exists, or we know it's been deleted and wasn't purged.
        let zoneState = try? ZoneState.fetch(context: persistentContainer.viewContext, for: zoneID, in: database)
        if zoneState == nil || (zoneState!.shouldDelete && !zoneState!.isPurged) {
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

        if let savedRecords = savedRecords,
            !savedRecords.isEmpty
        {
            debugPrint(savedRecords)
            do {
                for record in savedRecords {
                    try self.syncObjectFromRecord(record, in: context, updateValues: false)
                }

                try context.save()
                delegate?.cloudProvider(self, didSaveRecords: savedRecords)
            } catch {
                if let delegate = self.delegate {
                    print("Failed to write back: \(error)")
                    delegate.cloudProvider(self, didFailWithError: error)
                    return
                } else {
                    fatalError("Failed to write back: \(error)")
                }
            }
        }

        if let deletedRecordIDs = deletedRecordIDs,
            !deletedRecordIDs.isEmpty
        {
            debugPrint(deletedRecordIDs)
            delegate?.cloudProvider(self, didDeleteRecordsWithIDs: deletedRecordIDs)
        }
    }

    /// Sync an object from a CloudKit record.
    ///
    /// The existing object with the given `recordID`, or a newly created object if one does not
    /// exist, is synchronised with the contents of the CloudKit `record`.
    ///
    /// - Parameters:
    ///   - record: CloudKit record to synchronize to the object.
    ///   - context: managed object context for the fetch and creation.
    ///   - updateValues: set to `false` if values in `record` should be ignored, and only the
    ///     object `systemFields` updated.
    func syncObjectFromRecord(_ record: CKRecord, in context: NSManagedObjectContext, updateValues: Bool = true) throws {
        guard let storableType = storableTypes.first(where: { $0.recordType == record.recordType }) else { return }
        try storableType.syncObjectFromRecord(record, in: context, updateValues: updateValues)
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
                // FIXME: After creating the zone, we were storing the equivalent of a ZoneState
                // without a change token. This was when we had to always fetch all zones because
                // we didn't track which ones changed between runs in the table like we do now with
                // ZoneState.
                //
                // In theory this shouldn't be necessary anymore, while we won't automatically
                // fetch the new zone after creating it, we should still eventually get a change
                // from the server that creates the ZoneState for it.
                //
                // Keep this comment until I prove that to myself.
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
                if let delegate = self.delegate {
                    print("Failed to fetch long-lived operations: \(error)")
                    delegate.cloudProvider(self, didFailWithError: error)
                    return
                } else {
                    fatalError("Failed to fetch long-lived operations: \(error)")
                }
            }

            guard let operationIDs = operationIDs else { return }
            for operationID in operationIDs {
                self.container.fetchLongLivedOperation(withID: operationID) { (operation, error) in
                    if let error = error {
                        if let delegate = self.delegate {
                            print("Long-lived operation \(operationID) failed: \(error)")
                            delegate.cloudProvider(self, didFailWithError: error)
                            return
                        } else {
                            fatalError("Long-lived operation \(operationID) failed: \(error)")
                        }
                    }

                    if let operation = operation as? CKModifyRecordsOperation {
                        operation.modifyRecordsCompletionBlock = { (savedRecords, deletedRecordIDs, error) in
                            if let error = error {
                                if let delegate = self.delegate {
                                    print("Resuming long-lived modify operation \(operationID) failed: \(error)")
                                    delegate.cloudProvider(self, didFailWithError: error)
                                    return
                                } else {
                                    fatalError("Resuming long-lived modify operation \(operationID) failed: \(error)")
                                }
                            }


                            self.handleModifyCompletion(savedRecords: savedRecords, deletedRecordIDs: deletedRecordIDs)
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
